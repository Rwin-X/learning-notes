import time

import pytest

pytest.importorskip("PyQt6")
pytest.importorskip("matplotlib")

from PyQt6.QtCore import Qt  # noqa: E402
from PyQt6.QtWidgets import QApplication, QMessageBox  # noqa: E402

from regression_studio.core.models import ModelKind  # noqa: E402
from regression_studio.ui.main_window import MainWindow  # noqa: E402
from regression_studio.ui.style import build_stylesheet  # noqa: E402


@pytest.fixture(scope="module")
def app():
    instance = QApplication.instance() or QApplication([])
    instance.setStyleSheet(build_stylesheet())
    return instance


@pytest.fixture
def window(app, monkeypatch):
    warnings: list[str] = []
    monkeypatch.setattr(QMessageBox, "warning", lambda parent, title, text: warnings.append(text))
    win = MainWindow()
    win.warnings = warnings
    win.show()
    yield win
    win.close()


def wait_until(app, predicate, timeout=15.0):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        app.processEvents()
        if predicate():
            return True
        time.sleep(0.01)
    return False


def finish(app, win):
    assert wait_until(app, lambda: not win._fit_runner.busy)


def select_kind(win, kind):
    win.model_combo.setCurrentIndex(win.model_combo.findData(kind))


def test_fit_on_sample_data(app, window):
    window._load_sample()
    select_kind(window, ModelKind.POLYNOMIAL)
    window._run_fit()
    assert wait_until(app, lambda: window._result is not None)
    finish(app, window)
    assert window._result.spec.degree == 2
    assert window.cards["n"]._value.text() == "40"
    assert window.coef_table.rowCount() == 3
    assert "y = " in window.equation_label.text()
    assert window.btn_predict.isEnabled()
    window.predict_input.setText("5")
    window._predict()
    assert "y = " in window.predict_output.toPlainText()
    assert not window.grab().isNull()
    assert not window.warnings


def test_multiple_regression_and_selection_rules(app, window):
    window._load_sample()
    select_kind(window, ModelKind.LINEAR)
    # Single-predictor models keep exactly one predictor: checking z replaces x.
    window.x_list.item(1).setCheckState(Qt.CheckState.Checked)
    assert window._checked_x() == ["z"]
    # Multiple regression allows several.
    select_kind(window, ModelKind.MULTIPLE)
    window.x_list.item(0).setCheckState(Qt.CheckState.Checked)
    assert window._checked_x() == ["x", "z"]
    # The response column can never be a predictor.
    window.x_list.item(2).setCheckState(Qt.CheckState.Checked)
    assert "y" not in window._checked_x()
    window._run_fit()
    assert wait_until(app, lambda: window._result is not None)
    finish(app, window)
    assert window._result.x.shape[1] == 2


def test_errors_are_reported_not_raised(app, window):
    window.table_model.set_table(["x", "y"], [["1", "a"], ["2", "b"], ["3", "c"]])
    window._run_fit()
    assert wait_until(app, lambda: bool(window.warnings))
    finish(app, window)
    assert "not numeric" in window.warnings[0]
    assert window._result is None


def test_compare_fills_table(app, window):
    window._load_sample()
    window._run_compare()
    assert wait_until(app, lambda: window.compare_table.rowCount() > 0)
    finish(app, window)
    assert window.compare_table.rowCount() == 6


def test_paste_with_header_row(app, window):
    window.table_model.paste_block(0, 0, [["age", "height"], ["10", "140"], ["12", "152"]])
    assert window.table_model.headers[:2] == ["age", "height"]
    assert window.table_model.rows[0][:2] == ["10", "140"]
    assert window.y_combo.findText("height") >= 0


def test_export_report_and_plot(app, window, tmp_path, monkeypatch):
    from PyQt6.QtWidgets import QFileDialog

    window._load_sample()
    window._run_fit()
    assert wait_until(app, lambda: window._result is not None)
    finish(app, window)
    report, plot = tmp_path / "r.txt", tmp_path / "p.png"
    monkeypatch.setattr(QFileDialog, "getSaveFileName", lambda *a, **k: (str(report), ""))
    window._export_report()
    monkeypatch.setattr(QFileDialog, "getSaveFileName", lambda *a, **k: (str(plot), ""))
    window._export_plot()
    assert "REGRESSION REPORT" in report.read_text(encoding="utf-8")
    assert plot.stat().st_size > 1000

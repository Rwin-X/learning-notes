"""Main window: sidebar controls, metric cards and the tabbed workspace."""

from __future__ import annotations

from pathlib import Path

from PyQt6.QtCore import QEvent, Qt
from PyQt6.QtGui import QKeySequence, QShortcut
from PyQt6.QtWidgets import (
    QAbstractItemView,
    QFileDialog,
    QHBoxLayout,
    QInputDialog,
    QLabel,
    QLineEdit,
    QListWidget,
    QListWidgetItem,
    QMainWindow,
    QMessageBox,
    QPlainTextEdit,
    QPushButton,
    QSizeGrip,
    QTabWidget,
    QVBoxLayout,
    QWidget,
)

from regression_studio import APP_NAME
from regression_studio.core.data import parse_points, sample_table
from regression_studio.core.engine import MAX_DEGREE, analyze, analyze_compare, predict
from regression_studio.core.io import read_table, write_csv
from regression_studio.core.models import (
    AnalysisError,
    ComparisonRow,
    FitResult,
    ModelKind,
    ModelSpec,
)
from regression_studio.core.report import (
    build_report,
    coefficient_headers,
    coefficient_rows,
    fmt,
    fmt_p,
    format_prediction,
)

from .plots import DiagnosticsPlot, FitPlot, ResidualPlot, _PlotBase
from .table import DataTableModel, DataTableView
from .title_bar import TitleBar
from .widgets import (
    ArrowComboBox,
    MetricCard,
    fill_table,
    labeled,
    make_readonly_table,
    section_label,
)
from .workers import TaskRunner


class MainWindow(QMainWindow):
    def __init__(self) -> None:
        super().__init__()
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.setWindowTitle(APP_NAME)
        self._result: FitResult | None = None
        self._syncing = False

        self.table_model = DataTableModel(self)
        self._fit_runner = TaskRunner(self)
        self._io_runner = TaskRunner(self)

        self._build_ui()
        self._connect_signals()
        self._refresh_columns()
        self._update_model_controls()
        self.resize(1280, 800)
        self.setMinimumSize(1000, 680)

    # --- construction -------------------------------------------------------

    def _build_ui(self) -> None:
        central = QWidget()
        central.setObjectName("rootContainer")
        central.setAttribute(Qt.WidgetAttribute.WA_StyledBackground, True)
        root = QVBoxLayout(central)
        root.setContentsMargins(1, 1, 1, 1)
        root.setSpacing(0)

        self.title_bar = TitleBar(self, APP_NAME)
        root.addWidget(self.title_bar)

        body = QWidget()
        body_layout = QHBoxLayout(body)
        body_layout.setContentsMargins(0, 0, 0, 0)
        body_layout.setSpacing(0)
        body_layout.addWidget(self._build_sidebar())
        body_layout.addWidget(self._build_workspace(), 1)
        root.addWidget(body, 1)

        footer = QWidget()
        footer.setObjectName("footerBar")
        footer.setAttribute(Qt.WidgetAttribute.WA_StyledBackground, True)
        footer_layout = QHBoxLayout(footer)
        footer_layout.setContentsMargins(16, 4, 4, 4)
        self.status_label = QLabel("Enter data, paste from a spreadsheet, or open a CSV file.")
        self.status_label.setObjectName("tertiaryLabel")
        self.size_grip = QSizeGrip(self)
        footer_layout.addWidget(self.status_label, 1)
        footer_layout.addWidget(self.size_grip, 0, Qt.AlignmentFlag.AlignBottom | Qt.AlignmentFlag.AlignRight)
        root.addWidget(footer)

        self.setCentralWidget(central)

    def _build_sidebar(self) -> QWidget:
        side = QWidget()
        side.setObjectName("sidebar")
        side.setAttribute(Qt.WidgetAttribute.WA_StyledBackground, True)
        side.setFixedWidth(300)
        lay = QVBoxLayout(side)
        lay.setContentsMargins(16, 16, 16, 16)
        lay.setSpacing(8)

        lay.addWidget(section_label("Data"))
        row = QHBoxLayout()
        row.setSpacing(8)
        self.btn_open = QPushButton("Open")
        self.btn_save = QPushButton("Save")
        self.btn_sample = QPushButton("Sample")
        for button in (self.btn_open, self.btn_save, self.btn_sample):
            row.addWidget(button)
        lay.addLayout(row)
        lay.addSpacing(8)

        lay.addWidget(section_label("Model"))
        self.model_combo = ArrowComboBox()
        for kind in ModelKind:
            self.model_combo.addItem(kind.label, kind)
        lay.addWidget(labeled("Regression type", self.model_combo))

        self.degree_combo = ArrowComboBox()
        self.degree_combo.addItems([str(d) for d in range(1, MAX_DEGREE + 1)])
        self.degree_combo.setCurrentIndex(1)  # degree 2
        self.degree_field = labeled("Polynomial degree", self.degree_combo)
        lay.addWidget(self.degree_field)

        self.y_combo = ArrowComboBox()
        lay.addWidget(labeled("Response (y)", self.y_combo))

        self.x_list = QListWidget()
        self.x_list.setFixedHeight(96)
        self.x_list.setSelectionMode(QAbstractItemView.SelectionMode.NoSelection)
        lay.addWidget(labeled("Predictors (x)", self.x_list))

        run_row = QHBoxLayout()
        run_row.setSpacing(8)
        self.btn_run = QPushButton("Run")
        self.btn_run.setObjectName("primaryAction")
        self.btn_run.setToolTip("Fit the model (F5)")
        self.btn_compare = QPushButton("Compare")
        self.btn_compare.setToolTip("Fit all single-predictor models and rank them")
        run_row.addWidget(self.btn_run)
        run_row.addWidget(self.btn_compare)
        lay.addLayout(run_row)
        lay.addSpacing(8)

        lay.addWidget(section_label("Predict"))
        predict_row = QHBoxLayout()
        predict_row.setSpacing(8)
        self.predict_input = QLineEdit()
        self.predict_input.setPlaceholderText("Fit a model first")
        self.btn_predict = QPushButton("Go")
        self.btn_predict.setFixedWidth(56)
        predict_row.addWidget(self.predict_input, 1)
        predict_row.addWidget(self.btn_predict)
        lay.addLayout(predict_row)
        self.predict_output = QPlainTextEdit()
        self.predict_output.setObjectName("monoText")
        self.predict_output.setReadOnly(True)
        self.predict_output.setFixedHeight(120)
        lay.addWidget(self.predict_output)
        lay.addSpacing(8)

        lay.addWidget(section_label("Export"))
        export_row = QHBoxLayout()
        export_row.setSpacing(8)
        self.btn_export_plot = QPushButton("Plot")
        self.btn_export_report = QPushButton("Report")
        export_row.addWidget(self.btn_export_plot)
        export_row.addWidget(self.btn_export_report)
        lay.addLayout(export_row)
        lay.addStretch(1)

        for button in (self.btn_predict, self.btn_export_plot, self.btn_export_report):
            button.setEnabled(False)
        return side

    def _build_workspace(self) -> QWidget:
        work = QWidget()
        lay = QVBoxLayout(work)
        lay.setContentsMargins(16, 16, 16, 12)
        lay.setSpacing(12)

        cards = QHBoxLayout()
        cards.setSpacing(12)
        self.cards: dict[str, MetricCard] = {}
        for key, title in (
            ("r2", "R\u00b2"),
            ("adj_r2", "Adjusted R\u00b2"),
            ("rmse", "RMSE"),
            ("mae", "MAE"),
            ("f_p", "F-test p-value"),
            ("n", "Observations"),
        ):
            self.cards[key] = MetricCard(title)
            cards.addWidget(self.cards[key])
        lay.addLayout(cards)

        self.tabs = QTabWidget()
        self.fit_plot = FitPlot()
        self.resid_plot = ResidualPlot()
        self.diag_plot = DiagnosticsPlot()
        self.tabs.addTab(self._build_data_page(), "Data")
        self.tabs.addTab(self.fit_plot, "Fit")
        self.tabs.addTab(self.resid_plot, "Residuals")
        self.tabs.addTab(self.diag_plot, "Diagnostics")
        self.tabs.addTab(self._build_results_page(), "Results")
        self.tabs.addTab(self._build_compare_page(), "Compare")
        self.report_view = QPlainTextEdit()
        self.report_view.setObjectName("monoText")
        self.report_view.setReadOnly(True)
        self.report_view.setPlaceholderText("The full text report appears here after a fit.")
        self.tabs.addTab(self.report_view, "Report")
        lay.addWidget(self.tabs, 1)
        return work

    def _build_data_page(self) -> QWidget:
        page = QWidget()
        lay = QVBoxLayout(page)
        lay.setContentsMargins(12, 12, 12, 12)
        lay.setSpacing(8)
        bar = QHBoxLayout()
        bar.setSpacing(8)
        self.btn_add_row = QPushButton("Add row")
        self.btn_del_rows = QPushButton("Delete rows")
        self.btn_add_col = QPushButton("Add column")
        self.btn_del_col = QPushButton("Delete column")
        self.btn_clear = QPushButton("Clear")
        for button in (self.btn_add_row, self.btn_del_rows, self.btn_add_col,
                       self.btn_del_col, self.btn_clear):
            bar.addWidget(button)
        bar.addStretch(1)
        hint = QLabel("Double-click a header to rename. Ctrl+V pastes from a spreadsheet.")
        hint.setObjectName("tertiaryLabel")
        bar.addWidget(hint)
        lay.addLayout(bar)
        self.table_view = DataTableView()
        self.table_view.setModel(self.table_model)
        self.table_view.horizontalHeader().setDefaultSectionSize(110)
        self.table_view.verticalHeader().setDefaultSectionSize(26)
        lay.addWidget(self.table_view, 1)
        return page

    def _build_results_page(self) -> QWidget:
        page = QWidget()
        lay = QVBoxLayout(page)
        lay.setContentsMargins(16, 16, 16, 16)
        lay.setSpacing(10)
        self.equation_label = QLabel("No model fitted yet.")
        self.equation_label.setObjectName("equationLabel")
        self.equation_label.setWordWrap(True)
        self.equation_label.setTextInteractionFlags(Qt.TextInteractionFlag.TextSelectableByMouse)
        lay.addWidget(self.equation_label)
        self.coef_table = make_readonly_table(["Term", "Estimate", "Std. error", "t", "p-value", "CI low", "CI high"])
        lay.addWidget(self.coef_table, 1)
        self.notes_label = QLabel("")
        self.notes_label.setObjectName("tertiaryLabel")
        self.notes_label.setWordWrap(True)
        lay.addWidget(self.notes_label)
        return page

    def _build_compare_page(self) -> QWidget:
        page = QWidget()
        lay = QVBoxLayout(page)
        lay.setContentsMargins(16, 16, 16, 16)
        lay.setSpacing(10)
        self.compare_note = QLabel("Press Compare to rank all single-predictor models on your data.")
        self.compare_note.setObjectName("secondaryLabel")
        self.compare_note.setWordWrap(True)
        lay.addWidget(self.compare_note)
        self.compare_table = make_readonly_table(
            ["Model", "R\u00b2", "Adjusted R\u00b2", "RMSE", "CV RMSE", "Note"]
        )
        lay.addWidget(self.compare_table, 1)
        return page

    def _connect_signals(self) -> None:
        self.btn_open.clicked.connect(self._open_csv)
        self.btn_save.clicked.connect(self._save_csv)
        self.btn_sample.clicked.connect(self._load_sample)
        self.btn_run.clicked.connect(self._run_fit)
        self.btn_compare.clicked.connect(self._run_compare)
        self.btn_predict.clicked.connect(self._predict)
        self.predict_input.returnPressed.connect(self._predict)
        self.btn_export_plot.clicked.connect(self._export_plot)
        self.btn_export_report.clicked.connect(self._export_report)

        self.btn_add_row.clicked.connect(lambda: self.table_model.insert_rows(1))
        self.btn_del_rows.clicked.connect(self._delete_rows)
        self.btn_add_col.clicked.connect(self.table_model.add_column)
        self.btn_del_col.clicked.connect(self._delete_column)
        self.btn_clear.clicked.connect(self.table_model.clear)
        self.table_view.horizontalHeader().sectionDoubleClicked.connect(self._rename_column)

        for signal in (
            self.table_model.headerDataChanged,
            self.table_model.modelReset,
            self.table_model.columnsInserted,
            self.table_model.columnsRemoved,
        ):
            signal.connect(self._refresh_columns)

        self.model_combo.currentIndexChanged.connect(self._update_model_controls)
        self.y_combo.currentIndexChanged.connect(self._on_y_changed)
        self.x_list.itemChanged.connect(self._on_x_changed)

        for runner in (self._fit_runner, self._io_runner):
            runner.busy_changed.connect(self._set_busy)

        for sequence in ("F5", "Ctrl+Return"):
            QShortcut(QKeySequence(sequence), self).activated.connect(self._run_fit)

    # --- column / model selection ---------------------------------------------

    def _current_kind(self) -> ModelKind:
        return self.model_combo.currentData()

    def _checked_x(self) -> list[str]:
        return [
            self.x_list.item(i).text()
            for i in range(self.x_list.count())
            if self.x_list.item(i).checkState() == Qt.CheckState.Checked
        ]

    def _refresh_columns(self, *_args) -> None:
        names = self.table_model.headers
        previous_y = self.y_combo.currentText()
        previous_x = set(self._checked_x())
        self._syncing = True
        self.y_combo.clear()
        self.y_combo.addItems(names)
        index = self.y_combo.findText(previous_y)
        self.y_combo.setCurrentIndex(index if index >= 0 else len(names) - 1)
        self.x_list.clear()
        for name in names:
            item = QListWidgetItem(name)
            item.setFlags(item.flags() | Qt.ItemFlag.ItemIsUserCheckable)
            item.setCheckState(
                Qt.CheckState.Checked if name in previous_x else Qt.CheckState.Unchecked
            )
            self.x_list.addItem(item)
        self._syncing = False
        self._normalize_x_selection()

    def _normalize_x_selection(self) -> None:
        """Keep predictors valid: not the response, one only for single-x models."""
        if self._syncing:
            return
        self._syncing = True
        y_name = self.y_combo.currentText()
        multiple = self._current_kind() is ModelKind.MULTIPLE
        seen_checked = False
        for i in range(self.x_list.count()):
            item = self.x_list.item(i)
            if item.text() == y_name:
                item.setCheckState(Qt.CheckState.Unchecked)
            elif item.checkState() == Qt.CheckState.Checked:
                if seen_checked and not multiple:
                    item.setCheckState(Qt.CheckState.Unchecked)
                seen_checked = True
        if not seen_checked:
            for i in range(self.x_list.count()):
                item = self.x_list.item(i)
                if item.text() != y_name:
                    item.setCheckState(Qt.CheckState.Checked)
                    break
        self._syncing = False

    def _on_y_changed(self, *_args) -> None:
        self._normalize_x_selection()

    def _on_x_changed(self, item: QListWidgetItem) -> None:
        if self._syncing:
            return
        if self._current_kind() is not ModelKind.MULTIPLE and item.checkState() == Qt.CheckState.Checked:
            self._syncing = True
            for i in range(self.x_list.count()):
                other = self.x_list.item(i)
                if other is not item:
                    other.setCheckState(Qt.CheckState.Unchecked)
            self._syncing = False
        if item.text() == self.y_combo.currentText():
            self._syncing = True
            item.setCheckState(Qt.CheckState.Unchecked)
            self._syncing = False

    def _update_model_controls(self, *_args) -> None:
        self.degree_field.setVisible(self._current_kind() is ModelKind.POLYNOMIAL)
        self._normalize_x_selection()

    def _read_spec(self) -> ModelSpec:
        predictors = tuple(self._checked_x())
        if not predictors:
            raise AnalysisError("Select a predictor column.")
        return ModelSpec(
            self._current_kind(), self.y_combo.currentText(), predictors, int(self.degree_combo.currentText())
        )

    # --- table editing ------------------------------------------------------------

    def _delete_rows(self) -> None:
        rows = {i.row() for i in self.table_view.selectionModel().selectedIndexes()}
        if not rows and self.table_view.currentIndex().isValid():
            rows = {self.table_view.currentIndex().row()}
        self.table_model.remove_rows(sorted(rows))

    def _delete_column(self) -> None:
        index = self.table_view.currentIndex()
        if index.isValid():
            self.table_model.remove_column(index.column())

    def _rename_column(self, section: int) -> None:
        name, accepted = QInputDialog.getText(
            self, "Rename column", "Column name:", text=self.table_model.headers[section]
        )
        if accepted and not self.table_model.rename_column(section, name):
            self._notify("Column names must be non-empty and unique.")

    # --- files --------------------------------------------------------------------

    def _open_csv(self) -> None:
        path, _ = QFileDialog.getOpenFileName(
            self, "Open data", "", "Data files (*.csv *.tsv *.txt);;All files (*)"
        )
        if path:
            self._set_status(f"Loading {Path(path).name}...")
            self._io_runner.start(
                read_table, path,
                on_success=lambda res, p=path: self._on_loaded(p, res),
                on_failure=self._on_task_failed,
            )

    def _on_loaded(self, path: str, table: tuple[list[str], list[list[str]]]) -> None:
        headers, rows = table
        self.table_model.set_table(headers, rows)
        self.tabs.setCurrentIndex(0)
        self._set_status(f"Loaded {len(rows)} rows, {len(headers)} columns from {Path(path).name}.")

    def _save_csv(self) -> None:
        path, _ = QFileDialog.getSaveFileName(self, "Save data", "data.csv", "CSV (*.csv)")
        if path:
            headers = list(self.table_model.headers)
            rows = [list(r) for r in self.table_model.rows]
            self._io_runner.start(
                write_csv, path, headers, rows,
                on_success=lambda count, p=path: self._set_status(f"Saved {count} rows to {Path(p).name}."),
                on_failure=self._on_task_failed,
            )

    def _load_sample(self) -> None:
        headers, rows = sample_table()
        self.table_model.set_table(headers, rows)
        self.tabs.setCurrentIndex(0)
        self._set_status("Sample data loaded: y depends on x (quadratic) and z (linear).")

    # --- analysis -------------------------------------------------------------------

    def _snapshot(self) -> tuple[list[str], list[list[str]]]:
        return list(self.table_model.headers), [list(r) for r in self.table_model.rows]

    def _run_fit(self) -> None:
        if self._fit_runner.busy:
            return
        try:
            spec = self._read_spec()
        except AnalysisError as exc:
            self._notify(str(exc))
            return
        headers, rows = self._snapshot()
        self._set_status("Fitting...")
        self._fit_runner.start(
            analyze, headers, rows, spec,
            on_success=self._on_fit_done, on_failure=self._on_task_failed,
        )

    def _run_compare(self) -> None:
        if self._fit_runner.busy:
            return
        predictors = self._checked_x()
        if len(predictors) != 1:
            self._notify("Comparison needs exactly one predictor column.")
            return
        headers, rows = self._snapshot()
        self._set_status("Comparing models...")
        self._fit_runner.start(
            analyze_compare, headers, rows, predictors[0], self.y_combo.currentText(),
            on_success=lambda res, x=predictors[0], y=self.y_combo.currentText(): self._on_compare_done(x, y, res),
            on_failure=self._on_task_failed,
        )

    def _on_fit_done(self, result: FitResult) -> None:
        self._result = result
        self.cards["r2"].set_value(fmt(result.r2, 4))
        self.cards["adj_r2"].set_value(fmt(result.adj_r2, 4))
        self.cards["rmse"].set_value(fmt(result.rmse, 5))
        self.cards["mae"].set_value(fmt(result.mae, 5))
        self.cards["f_p"].set_value(fmt_p(result.f_p))
        self.cards["n"].set_value(str(result.n))

        self.fit_plot.render(result)
        self.resid_plot.render(result)
        self.diag_plot.render(result)

        self.equation_label.setText(result.equation)
        self.coef_table.setHorizontalHeaderLabels(coefficient_headers(result))
        fill_table(self.coef_table, coefficient_rows(result))
        self.notes_label.setText("  ".join(result.notes))
        self.report_view.setPlainText(build_report(result))

        names = ", ".join(result.spec.x_cols)
        self.predict_input.setPlaceholderText(
            "e.g. 2.5, 4, 7" if len(result.spec.x_cols) == 1 else f"{names}  (; between points)"
        )
        self.predict_output.clear()
        for button in (self.btn_predict, self.btn_export_plot, self.btn_export_report):
            button.setEnabled(True)
        self.tabs.setCurrentWidget(self.fit_plot)
        skipped = f", {result.n_dropped} incomplete rows skipped" if result.n_dropped else ""
        self._set_status(f"{result.spec.describe()} fitted on {result.n} rows{skipped}.")

    def _on_compare_done(self, x_col: str, y_col: str, payload: tuple[list[ComparisonRow], int]) -> None:
        rows, n = payload
        fill_table(
            self.compare_table,
            [
                [r.label, fmt(r.r2, 4), fmt(r.adj_r2, 4), fmt(r.rmse, 5), fmt(r.cv_rmse, 5), r.note]
                for r in rows
            ],
            accent_first=True,
        )
        self.compare_note.setText(
            f"{y_col} vs {x_col}, {n} rows. Ranked by 5-fold cross-validated RMSE "
            "(lower is better); R\u00b2 and RMSE are in-sample and favour complex models."
        )
        self.tabs.setCurrentIndex(self.tabs.indexOf(self.compare_table.parentWidget()))
        self._set_status("Model comparison finished.")

    def _on_task_failed(self, message: str) -> None:
        self._set_status("Failed.")
        self._notify(message)

    def _predict(self) -> None:
        if self._result is None:
            return
        try:
            points = parse_points(self.predict_input.text(), self._result.x.shape[1])
            pred = predict(self._result, points)
        except AnalysisError as exc:
            self.predict_output.setPlainText(f"Error: {exc}")
            return
        self.predict_output.setPlainText(format_prediction(self._result, pred))

    # --- export -------------------------------------------------------------------

    def _export_plot(self) -> None:
        current = self.tabs.currentWidget()
        canvas = current if isinstance(current, _PlotBase) else self.fit_plot
        path, _ = QFileDialog.getSaveFileName(
            self, "Export plot", "plot.png", "PNG (*.png);;SVG (*.svg);;PDF (*.pdf)"
        )
        if path:
            if not Path(path).suffix:
                path += ".png"
            canvas.figure.savefig(path, dpi=200, facecolor=canvas.figure.get_facecolor())
            self._set_status(f"Plot saved to {Path(path).name}.")

    def _export_report(self) -> None:
        if self._result is None:
            return
        path, _ = QFileDialog.getSaveFileName(
            self, "Export report", "regression_report.txt", "Text (*.txt)"
        )
        if path:
            Path(path).write_text(build_report(self._result), encoding="utf-8")
            self._set_status(f"Report saved to {Path(path).name}.")

    # --- helpers --------------------------------------------------------------------

    def _set_busy(self, busy: bool) -> None:
        for button in (self.btn_run, self.btn_compare, self.btn_open, self.btn_save):
            button.setEnabled(not busy)

    def _set_status(self, text: str) -> None:
        self.status_label.setText(text)

    def _notify(self, message: str) -> None:
        QMessageBox.warning(self, APP_NAME, message)

    def changeEvent(self, event) -> None:
        if event.type() == QEvent.Type.WindowStateChange:
            self.title_bar.sync_maximize_glyph()
            self.size_grip.setVisible(not self.isMaximized())
        super().changeEvent(event)

    def closeEvent(self, event) -> None:
        self._fit_runner.shutdown()
        self._io_runner.shutdown()
        super().closeEvent(event)

"""Matplotlib canvases styled to match the application palette."""

from __future__ import annotations

import math
import os

os.environ.setdefault("QT_API", "pyqt6")

import numpy as np  # noqa: E402
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg  # noqa: E402
from matplotlib.figure import Figure  # noqa: E402

from regression_studio.core import stats  # noqa: E402
from regression_studio.core.engine import curve_grid, predict  # noqa: E402
from regression_studio.core.models import FitResult  # noqa: E402

from . import style  # noqa: E402


def _style_axis(ax) -> None:
    ax.set_facecolor(style.BG_SUNKEN)
    for spine in ax.spines.values():
        spine.set_color(style.BORDER)
    ax.tick_params(colors=style.TEXT_SECONDARY, labelsize=9)
    ax.xaxis.label.set_color(style.TEXT_SECONDARY)
    ax.yaxis.label.set_color(style.TEXT_SECONDARY)
    ax.grid(True, color=style.BORDER, linewidth=0.6, alpha=0.8)
    ax.set_axisbelow(True)


def _title(ax, text: str) -> None:
    ax.set_title(text, color=style.TEXT_PRIMARY, fontsize=11, loc="left")


def _legend(ax) -> None:
    ax.legend(
        facecolor=style.BG_ELEVATED,
        edgecolor=style.BORDER,
        labelcolor=style.TEXT_SECONDARY,
        fontsize=9,
        loc="best",
    )


class _PlotBase(FigureCanvasQTAgg):
    def __init__(self, ncols: int = 1) -> None:
        figure = Figure(figsize=(6, 4), dpi=100, facecolor=style.BG_BASE, layout="constrained")
        super().__init__(figure)
        self._axes = list(figure.subplots(1, ncols, squeeze=False)[0])
        self.setMinimumSize(240, 160)
        self.show_empty()

    def _reset(self) -> list:
        for ax in self._axes:
            ax.clear()
            _style_axis(ax)
        return self._axes

    def show_empty(self) -> None:
        for ax in self._reset():
            ax.set_xticks([])
            ax.set_yticks([])
        self._axes[0].text(
            0.5, 0.5, "Run a regression to see this plot.",
            transform=self._axes[0].transAxes, ha="center", va="center",
            color=style.TEXT_TERTIARY, fontsize=11,
        )
        self.draw_idle()


class FitPlot(_PlotBase):
    def render(self, r: FitResult) -> None:
        ax = self._reset()[0]
        pct = f"{r.level * 100:g}%"
        if r.x.shape[1] == 1:
            grid = curve_grid(r)
            pred = predict(r, grid[:, None])
            ax.scatter(r.x[:, 0], r.y, s=22, color=style.POINT, alpha=0.85,
                       linewidths=0, label="Observed", zorder=3)
            ax.fill_between(grid, pred.ci_low, pred.ci_high, color=style.ACCENT,
                            alpha=0.15, linewidth=0, label=f"{pct} confidence band")
            ax.plot(grid, pred.yhat, color=style.ACCENT, linewidth=2,
                    label=f"Fit (R\u00b2 = {r.r2:.3f})", zorder=4)
            lo = min(float(r.y.min()), float(pred.yhat.min()))
            hi = max(float(r.y.max()), float(pred.yhat.max()))
            pad = 0.08 * ((hi - lo) or 1.0)
            ax.set_ylim(lo - pad, hi + pad)
            ax.set_xlabel(r.spec.x_cols[0])
            ax.set_ylabel(r.spec.y_col)
            _title(ax, "Data and fitted model")
        else:
            lo = float(min(r.y.min(), r.fitted.min()))
            hi = float(max(r.y.max(), r.fitted.max()))
            ax.plot([lo, hi], [lo, hi], color=style.ACCENT, linewidth=2,
                    label=f"Perfect fit (R\u00b2 = {r.r2:.3f})", zorder=4)
            ax.scatter(r.fitted, r.y, s=22, color=style.POINT, alpha=0.85,
                       linewidths=0, label="Observations", zorder=3)
            ax.set_xlabel(f"Predicted {r.spec.y_col}")
            ax.set_ylabel(f"Observed {r.spec.y_col}")
            _title(ax, "Observed vs predicted")
        _legend(ax)
        self.draw_idle()


class ResidualPlot(_PlotBase):
    def render(self, r: FitResult) -> None:
        ax = self._reset()[0]
        ax.axhline(0.0, color=style.TEXT_TERTIARY, linewidth=1, linestyle="--")
        ax.scatter(r.fitted, r.residuals, s=22, color=style.POINT, alpha=0.85,
                   linewidths=0, zorder=3)
        ax.set_xlabel("Fitted values")
        ax.set_ylabel("Residuals")
        _title(ax, "Residuals vs fitted")
        self.draw_idle()


class DiagnosticsPlot(_PlotBase):
    def __init__(self) -> None:
        super().__init__(ncols=2)

    def show_empty(self) -> None:
        super().show_empty()
        self._axes[1].set_visible(False)

    def render(self, r: FitResult) -> None:
        hist_ax, qq_ax = self._reset()
        self._axes[1].set_visible(True)
        bins = min(40, max(5, int(math.sqrt(r.n)) + 1))
        hist_ax.hist(r.residuals, bins=bins, color=style.ACCENT, alpha=0.7,
                     edgecolor=style.BG_SUNKEN)
        hist_ax.set_xlabel("Residual")
        hist_ax.set_ylabel("Count")
        _title(hist_ax, "Residual distribution")

        slope, intercept = stats.qq_line(r.qq_theory, r.qq_sample)
        qq_ax.scatter(r.qq_theory, r.qq_sample, s=22, color=style.POINT, alpha=0.85,
                      linewidths=0, zorder=3)
        span = np.array([r.qq_theory.min(), r.qq_theory.max()])
        qq_ax.plot(span, slope * span + intercept, color=style.ACCENT, linewidth=2, zorder=4)
        qq_ax.set_xlabel("Theoretical quantiles")
        qq_ax.set_ylabel("Residual quantiles")
        _title(qq_ax, "Normal Q-Q")
        self.draw_idle()

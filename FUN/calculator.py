"""Minimal animated calculator.

Requirements:  pip install PyQt6
Run:           python calculator.py

Keep calculator_engine.py in the same folder. The engine holds the logic;
this file only draws the window and starts the animations.
"""

import math
import sys

from PyQt6.QtCore import QEasingCurve, QPointF, QRectF, Qt, QTimer, QVariantAnimation
from PyQt6.QtGui import (
    QBrush,
    QColor,
    QFont,
    QFontMetricsF,
    QPainter,
    QPainterPath,
    QPen,
    QRadialGradient,
)
from PyQt6.QtWidgets import (
    QAbstractButton,
    QApplication,
    QGridLayout,
    QSizePolicy,
    QVBoxLayout,
    QWidget,
)

from calculator_engine import EVENT_CALCULATED, EVENT_ERROR, CalculatorEngine

# ---------- Colors: all of them live here, in one place ----------
BG = QColor("#eceef2")
PANEL = QColor("#f8f9fb")
INK = QColor("#1c2230")
MUTE = QColor("#8a93a3")
LINE = QColor("#dde1e8")
ACCENT = QColor("#2f55d4")
ERROR = QColor("#c4473d")
WHITE = QColor("#ffffff")

# The first font found on the computer is used
FONT_FAMILIES = ["Jost", "Segoe UI", "Helvetica Neue", "Arial"]

EASE_OUT = QEasingCurve.Type.OutCubic
EASE_IN_OUT = QEasingCurve.Type.InOutCubic
LINEAR = QEasingCurve.Type.Linear


def make_font(pixel_size, weight):
    font = QFont()
    font.setFamilies(FONT_FAMILIES)
    font.setPixelSize(pixel_size)
    font.setWeight(weight)
    return font


def with_alpha(color, alpha):
    """Return a copy of a color with a different transparency (0.0 to 1.0)."""
    result = QColor(color)
    result.setAlphaF(alpha)
    return result


# =====================================================================
# Tween: one animated number
# =====================================================================
class Tween:
    """A number that moves smoothly from its current value to a target.

    Every animation in this file is a Tween. The widget reads tween.value
    inside paintEvent, and on_change (usually widget.update) redraws it.
    """

    def __init__(self, owner, duration, easing, on_change, value=0.0):
        self.value = float(value)
        self._on_change = on_change
        self._animation = QVariantAnimation(owner)
        self._animation.setDuration(duration)
        self._animation.setEasingCurve(easing)
        self._animation.valueChanged.connect(self._step)

    def _step(self, value):
        self.value = float(value)
        self._on_change()

    def go_to(self, target):
        self._animation.stop()
        self._animation.setStartValue(float(self.value))
        self._animation.setEndValue(float(target))
        self._animation.start()

    def restart(self, target=1.0):
        """Jump back to 0 and animate to the target again."""
        self.value = 0.0
        self.go_to(target)


# =====================================================================
# Display: history line + main number
# =====================================================================
class DisplayView(QWidget):
    NUMBER_TOP = 26.0
    NUMBER_HEIGHT = 76.0
    SIDE_PADDING = 12.0

    def __init__(self):
        super().__init__()
        self.setFixedHeight(104)

        self.text = ""
        self.history = ""
        self.is_error = False
        self.entering = set()  # positions of the characters that are rising in

        self.rise_tween = Tween(self, 450, EASE_OUT, self.update, value=1.0)
        self.fade_tween = Tween(self, 350, EASE_OUT, self.update, value=1.0)
        self.shake_tween = Tween(self, 400, LINEAR, self.update)

    def set_text(self, text, is_error):
        old = self.text
        self.is_error = is_error

        # Only characters that changed get the "rise" animation
        self.entering = {i for i, char in enumerate(text) if i >= len(old) or char != old[i]}
        self.text = text

        if self.entering:
            self.rise_tween.restart()
        else:
            self.update()

    def set_history(self, text):
        if text != self.history:
            self.history = text
            self.fade_tween.restart()

    def shake(self):
        self.shake_tween.restart()

    def _fit_font(self, text, max_width):
        """Largest font (60 px or smaller) in which the text still fits."""
        size = 60
        while size > 14:
            font = make_font(size, QFont.Weight.ExtraLight)
            width = sum(QFontMetricsF(font).horizontalAdvance(char) for char in text)
            if width <= max_width:
                return font
            size -= 2
        return make_font(14, QFont.Weight.ExtraLight)

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)
        painter.setRenderHint(QPainter.RenderHint.TextAntialiasing)

        # Shake: a sine wave that becomes smaller until it stops
        progress = self.shake_tween.value
        painter.translate(8.0 * math.sin(progress * math.pi * 5) * (1.0 - progress), 0)

        right = self.width() - self.SIDE_PADDING

        # History line, for example "12 + 3 ="
        fade = self.fade_tween.value
        painter.setOpacity(fade)
        painter.setFont(make_font(15, QFont.Weight.Light))
        painter.setPen(MUTE)
        history_rect = QRectF(0, 4.0 * (1.0 - fade), right, 22)
        painter.drawText(
            history_rect,
            Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter,
            self.history,
        )

        # Main number: the area clips its content, so new digits rise from below
        painter.setClipRect(QRectF(0, self.NUMBER_TOP, self.width(), self.NUMBER_HEIGHT))
        painter.setPen(ERROR if self.is_error else INK)

        font = self._fit_font(self.text, right)
        painter.setFont(font)
        metrics = QFontMetricsF(font)

        total_width = sum(metrics.horizontalAdvance(char) for char in self.text)
        x = right - total_width
        baseline = self.NUMBER_TOP + self.NUMBER_HEIGHT - metrics.descent() - 6

        rise = self.rise_tween.value
        for index, char in enumerate(self.text):
            if index in self.entering:
                painter.setOpacity(rise)
                offset = (1.0 - rise) * self.NUMBER_HEIGHT * 0.6
            else:
                painter.setOpacity(1.0)
                offset = 0.0

            painter.drawText(QPointF(x, baseline + offset), char)
            x += metrics.horizontalAdvance(char)


# =====================================================================
# Line under the display: drawn from left to right, then erased
# =====================================================================
class SweepLine(QWidget):
    def __init__(self):
        super().__init__()
        self.setFixedHeight(2)
        # Goes from 0 to 2: first half draws the line, second half erases it
        self.sweep_tween = Tween(self, 800, LINEAR, self.update)
        self.easing = QEasingCurve(EASE_IN_OUT)

    def play(self):
        self.sweep_tween.restart(2.0)

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)

        track = QRectF(12, 0, self.width() - 24, self.height())
        path = QPainterPath()
        path.addRoundedRect(track, 1, 1)
        painter.fillPath(path, LINE)

        value = self.sweep_tween.value
        if 0.0 < value < 2.0:
            if value < 1.0:
                start, end = 0.0, self.easing.valueForProgress(value)
            else:
                start, end = self.easing.valueForProgress(value - 1.0), 1.0

            painter.setClipPath(path)
            painter.fillRect(
                QRectF(track.left() + start * track.width(), 0, (end - start) * track.width(), 2),
                ACCENT,
            )


# =====================================================================
# Button: drawn by hand so it can have its own animations
# =====================================================================
class CalcButton(QAbstractButton):
    def __init__(self, label, kind):
        super().__init__()
        self.label = label
        self.kind = kind  # "digit", "operator", "clear" or "equals"
        self.mouse_pos = QPointF()
        self.is_active = False  # True while this operator is waiting for the second number

        self.appear_tween = Tween(self, 600, EASE_OUT, self.update)  # start-up animation
        self.hover_tween = Tween(self, 250, EASE_OUT, self.update)   # glow fades in and out
        self.press_tween = Tween(self, 150, EASE_OUT, self.update)   # button shrinks when pressed
        self.bar_tween = Tween(self, 300, EASE_OUT, self.update)     # bar under the operator

        self.setMouseTracking(True)
        self.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        self.setCursor(Qt.CursorShape.PointingHandCursor)
        self.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)
        self.setMinimumHeight(64)

        self.pressed.connect(lambda: self.press_tween.go_to(1.0))
        self.released.connect(lambda: self.press_tween.go_to(0.0))

    def play_intro(self, delay_ms):
        QTimer.singleShot(delay_ms, lambda: self.appear_tween.go_to(1.0))

    def flash(self):
        """Show the pressed look for a moment (used for keyboard input)."""
        self.press_tween.go_to(1.0)
        QTimer.singleShot(100, lambda: self.press_tween.go_to(0.0))

    def set_active(self, active):
        if active != self.is_active:
            self.is_active = active
            self.bar_tween.go_to(1.0 if active else 0.0)

    # ---------- Mouse events ----------
    def enterEvent(self, event):
        self.mouse_pos = event.position()
        self.hover_tween.go_to(1.0)
        super().enterEvent(event)

    def leaveEvent(self, event):
        self.hover_tween.go_to(0.0)
        super().leaveEvent(event)

    def mouseMoveEvent(self, event):
        self.mouse_pos = event.position()
        self.update()
        super().mouseMoveEvent(event)

    # ---------- Drawing ----------
    def _text_style(self):
        """Return (color, pixel size, weight) for this kind of button."""
        if self.kind == "equals":
            return WHITE, 26, QFont.Weight.Light
        if self.kind == "operator":
            return ACCENT, 26, QFont.Weight.Light
        if self.kind == "clear":
            return MUTE, 18, QFont.Weight.Normal
        return INK, 26, QFont.Weight.Light

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)
        painter.setRenderHint(QPainter.RenderHint.TextAntialiasing)

        appear = self.appear_tween.value
        painter.setOpacity(appear)

        # Scale around the center: small at start-up, smaller again while pressed
        scale = (0.88 + 0.12 * appear) * (1.0 - 0.07 * self.press_tween.value)
        center = QPointF(self.width() / 2, self.height() / 2)
        painter.translate(center)
        painter.scale(scale, scale)
        painter.translate(-center)

        rect = QRectF(self.rect())
        is_equals = self.kind == "equals"
        radius = 24 if is_equals else 20
        shape = QPainterPath()
        shape.addRoundedRect(rect, radius, radius)

        if is_equals:
            painter.fillPath(shape, ACCENT)

        # Soft glow that follows the pointer
        hover = self.hover_tween.value
        if hover > 0.0:
            glow_color = WHITE if is_equals else ACCENT
            glow_strength = 0.25 if is_equals else 0.16
            gradient = QRadialGradient(self.mouse_pos, 90 if is_equals else 70)
            gradient.setColorAt(0.0, with_alpha(glow_color, glow_strength * hover))
            gradient.setColorAt(1.0, with_alpha(glow_color, 0.0))

            painter.setClipPath(shape)
            painter.fillRect(rect, QBrush(gradient))
            painter.setClipping(False)

        # Label
        color, size, weight = self._text_style()
        painter.setPen(color)
        painter.setFont(make_font(size, weight))
        painter.drawText(rect, Qt.AlignmentFlag.AlignCenter, self.label)

        # Small bar under the operator that is waiting for the second number
        bar = self.bar_tween.value
        if bar > 0.0:
            bar_width = 16.0 * bar
            bar_rect = QRectF(center.x() - bar_width / 2, self.height() - 11, bar_width, 2)
            painter.setPen(Qt.PenStyle.NoPen)
            painter.setBrush(ACCENT)
            painter.drawRoundedRect(bar_rect, 1, 1)


# =====================================================================
# Panel: the rounded card behind the buttons
# =====================================================================
class Panel(QWidget):
    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)
        painter.setPen(QPen(LINE, 1))
        painter.setBrush(PANEL)
        painter.drawRoundedRect(QRectF(self.rect()).adjusted(0.5, 0.5, -0.5, -0.5), 32, 32)


# =====================================================================
# Main window
# =====================================================================
# (label shown, name, kind, row, column, row span, column span)
# The name is also the keyboard key that triggers the button.
BUTTON_LAYOUT = [
    ("AC", "AC", "clear", 0, 0, 1, 1),
    ("DEL", "DEL", "clear", 0, 1, 1, 1),
    ("\u00f7", "/", "operator", 0, 2, 1, 1),
    ("\u00d7", "*", "operator", 0, 3, 1, 1),
    ("7", "7", "digit", 1, 0, 1, 1),
    ("8", "8", "digit", 1, 1, 1, 1),
    ("9", "9", "digit", 1, 2, 1, 1),
    ("\u2212", "-", "operator", 1, 3, 1, 1),
    ("4", "4", "digit", 2, 0, 1, 1),
    ("5", "5", "digit", 2, 1, 1, 1),
    ("6", "6", "digit", 2, 2, 1, 1),
    ("+", "+", "operator", 2, 3, 1, 1),
    ("1", "1", "digit", 3, 0, 1, 1),
    ("2", "2", "digit", 3, 1, 1, 1),
    ("3", "3", "digit", 3, 2, 1, 1),
    ("=", "=", "equals", 3, 3, 2, 1),   # two rows tall
    ("0", "0", "digit", 4, 0, 1, 2),    # two columns wide
    (".", ".", "digit", 4, 2, 1, 1),
]

DIGIT_NAMES = set("0123456789.")
OPERATOR_NAMES = {"+", "-", "*", "/"}


class CalculatorWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Calculator")
        self.setMinimumSize(408, 620)
        self.resize(408, 640)

        self.engine = CalculatorEngine()
        self.display = DisplayView()
        self.line = SweepLine()
        self.buttons = {}  # name -> CalcButton

        # Card with the display, the line and the buttons
        panel = Panel()
        panel.setFixedWidth(360)
        panel_layout = QVBoxLayout(panel)
        panel_layout.setContentsMargins(22, 28, 22, 22)
        panel_layout.setSpacing(0)
        panel_layout.addWidget(self.display)
        panel_layout.addSpacing(14)
        panel_layout.addWidget(self.line)
        panel_layout.addSpacing(18)

        grid = QGridLayout()
        grid.setSpacing(6)
        for row in range(5):
            grid.setRowStretch(row, 1)

        for label, name, kind, row, column, row_span, column_span in BUTTON_LAYOUT:
            button = CalcButton(label, kind)
            # "name=name" saves the current name for this button
            button.clicked.connect(lambda checked=False, name=name: self.on_button(name))
            grid.addWidget(button, row, column, row_span, column_span)
            self.buttons[name] = button

        panel_layout.addLayout(grid, 1)

        outer = QVBoxLayout(self)
        outer.setContentsMargins(24, 24, 24, 24)
        outer.addWidget(panel, 1, Qt.AlignmentFlag.AlignHCenter)

    def paintEvent(self, event):
        QPainter(self).fillRect(self.rect(), BG)

    # ---------- Start-up animation ----------
    def play_intro(self):
        """The buttons appear one after another."""
        for index, name in enumerate(button[1] for button in BUTTON_LAYOUT):
            self.buttons[name].play_intro(index * 30)

    # ---------- Reacting to buttons ----------
    def on_button(self, name):
        if name in DIGIT_NAMES:
            self.engine.press_digit(name)
        elif name in OPERATOR_NAMES:
            self.engine.press_operator(name)
        elif name == "=":
            self.engine.press_equals()
        elif name == "AC":
            self.engine.clear_all()
        elif name == "DEL":
            self.engine.delete_last()

        self.refresh()

    def refresh(self):
        """Copy the engine state to the screen."""
        engine = self.engine
        self.display.set_text(engine.current, engine.current == "Error")
        self.display.set_history(engine.history_text)

        for operator in OPERATOR_NAMES:
            self.buttons[operator].set_active(engine.operator == operator)

        if engine.last_event == EVENT_CALCULATED:
            self.line.play()
        elif engine.last_event == EVENT_ERROR:
            self.display.shake()

    # ---------- Keyboard support ----------
    def keyPressEvent(self, event):
        key = event.key()

        if key in (Qt.Key.Key_Return, Qt.Key.Key_Enter, Qt.Key.Key_Equal):
            name = "="
        elif key == Qt.Key.Key_Backspace:
            name = "DEL"
        elif key == Qt.Key.Key_Escape:
            name = "AC"
        else:
            name = event.text()  # "7", "+", "*", "/", "-" or "."

        button = self.buttons.get(name)
        if button is None:
            super().keyPressEvent(event)
            return

        # Act immediately, so fast typing never loses a key, then show the pressed look
        self.on_button(name)
        button.flash()


def main():
    app = QApplication(sys.argv)
    window = CalculatorWindow()
    window.show()
    window.refresh()
    window.play_intro()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()

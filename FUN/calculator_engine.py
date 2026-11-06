"""Calculator logic.

Pure Python: this file has no GUI code, so it can be tested without a display.
The window (calculator.py) only calls these methods and reads the state.
"""

from decimal import Decimal, localcontext

# Symbols used only for showing an operator on screen
OPERATOR_SYMBOLS = {"+": "+", "-": "\u2212", "*": "\u00d7", "/": "\u00f7"}

MAX_DIGITS = 15       # the longest number a user can type
DECIMAL_PLACES = 10   # results are rounded to this many digits after the point

# Values of CalculatorEngine.last_event. The window uses them to start animations.
EVENT_CALCULATED = "calculated"
EVENT_ERROR = "error"


def compute(operator, a, b):
    """Calculate a (operator) b and return the result as clean text.

    Decimal is used instead of float, so 0.1 + 0.2 gives exactly 0.3.
    """
    with localcontext() as context:
        context.prec = 60

        if operator == "+":
            result = a + b
        elif operator == "-":
            result = a - b
        elif operator == "*":
            result = a * b
        else:
            result = a / b

        result = round(result, DECIMAL_PLACES)

        if result == 0:
            return "0"  # avoids "-0" and "0.0000000000"

        # normalize() removes trailing zeros, "f" prevents scientific notation
        return format(result.normalize(), "f")


class CalculatorEngine:
    """Holds the calculator state and changes it when a button is pressed."""

    def __init__(self):
        self.clear_all()

    # ---------- State ----------
    def clear_all(self):
        """AC button: reset everything."""
        self.current = "0"              # the number being typed, or the last result
        self.previous = ""              # the first number, saved when an operator is pressed
        self.operator = None            # "+", "-", "*", "/" or None
        self.waiting_for_second = False # True right after an operator is pressed
        self.just_calculated = False    # True right after "=" was pressed
        self.last_expression = ""       # text such as "12 + 3 =" shown after a calculation
        self.last_event = None          # EVENT_CALCULATED, EVENT_ERROR or None

    @property
    def history_text(self):
        """The small line above the main number."""
        if self.operator is not None:
            return self.previous + " " + OPERATOR_SYMBOLS[self.operator]
        return self.last_expression

    # ---------- Digit and decimal point buttons ----------
    def press_digit(self, digit):
        self.last_event = None

        # Start a fresh number after "=" or after choosing an operator
        if self.just_calculated or self.waiting_for_second:
            self.current = "0"
            if self.just_calculated:
                self.last_expression = ""
            self.just_calculated = False
            self.waiting_for_second = False

        # Do not allow two decimal points in one number
        if digit == "." and "." in self.current:
            return

        # Limit the length of the number
        if digit != "." and len(self.current.replace(".", "")) >= MAX_DIGITS:
            return

        # Replace the leading zero, unless we are typing "0."
        if self.current == "0" and digit != ".":
            self.current = digit
        else:
            self.current = self.current + digit

    # ---------- Operator buttons (+, -, *, /) ----------
    def press_operator(self, operator):
        self.last_event = None

        if self.current == "Error":
            return

        # A full expression is already typed (for example 2 + 3 and then +):
        # calculate it first so the operations can be chained
        if self.operator is not None and not self.waiting_for_second:
            self.press_equals()
            if self.current == "Error":
                return

        self.previous = self.current
        self.operator = operator
        self.waiting_for_second = True
        self.just_calculated = False

    # ---------- Equals button ----------
    def press_equals(self):
        self.last_event = None

        # Nothing to calculate yet
        if self.operator is None or self.waiting_for_second:
            return

        a = Decimal(self.previous)
        b = Decimal(self.current)

        if self.operator == "/" and b == 0:
            # Division by zero is not allowed
            self.current = "Error"
            self.previous = ""
            self.last_expression = ""
            self.operator = None
            self.just_calculated = True
            self.last_event = EVENT_ERROR
            return

        result = compute(self.operator, a, b)

        self.last_expression = (
            self.previous + " " + OPERATOR_SYMBOLS[self.operator] + " " + self.current + " ="
        )
        self.current = result
        self.previous = ""
        self.operator = None
        self.just_calculated = True
        self.last_event = EVENT_CALCULATED

    # ---------- DEL button: remove the last character ----------
    def delete_last(self):
        self.last_event = None

        if self.waiting_for_second:
            return

        if self.current == "Error" or self.just_calculated:
            self.clear_all()
            return

        if len(self.current) > 1:
            self.current = self.current[:-1]
        else:
            self.current = "0"

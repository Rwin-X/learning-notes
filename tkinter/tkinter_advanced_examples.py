"""
Tkinter Advanced Examples Collection
=====================================
Advanced, practical Tkinter patterns in a single file — the topics that
come up once you move past basic widgets: ttk theming, threading with
the GUI thread, canvas animation, custom reusable widget classes,
Treeview tables, drag-and-drop, matplotlib embedding, and a full
multi-tab application tying it all together.

Each example is self-contained in its own function. Pick one at the
bottom of the file and run:

    python3 tkinter_advanced_examples.py

Some examples need extra packages (see the comment above each one).
Everything else uses only the standard library.
"""

import tkinter as tk
from tkinter import ttk, messagebox
import threading
import time
import random
import queue


# ─────────────────────────────────────────────────────────────────────────
# 1 — ttk theming and styling
# ─────────────────────────────────────────────────────────────────────────
def example_1_ttk_styling():
    """
    ttk widgets look native to the OS and support a real styling system
    (ttk.Style) that plain tk widgets do not. This is the standard choice
    for any interface meant to look modern.
    """
    root = tk.Tk()
    root.title("ttk Styling Example")
    root.geometry("360x220")

    style = ttk.Style()
    style.theme_use("clam")  # try: 'clam', 'alt', 'default', 'classic'

    style.configure(
        "Accent.TButton",
        font=("Arial", 11, "bold"),
        foreground="white",
        background="#2d6cdf",
        padding=8,
    )
    style.map("Accent.TButton", background=[("active", "#1e4fa3")])

    style.configure("TLabel", font=("Arial", 11))
    style.configure("Header.TLabel", font=("Arial", 15, "bold"))

    ttk.Label(root, text="ttk Styled Interface", style="Header.TLabel").pack(pady=(20, 10))
    ttk.Label(root, text="Themed widgets follow the OS look and feel.").pack(pady=5)

    ttk.Button(root, text="Primary Action", style="Accent.TButton").pack(pady=10)
    ttk.Button(root, text="Secondary Action").pack()

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 2 — Threading: keeping the GUI responsive during long tasks
# ─────────────────────────────────────────────────────────────────────────
def example_2_threading():
    """
    Tkinter's mainloop runs on a single thread. Any slow work done
    directly inside a callback (a network call, heavy computation) freezes
    the window. The fix: run the work on a background thread, and use a
    thread-safe queue to hand results back to the GUI thread, which polls
    it with root.after().
    """
    root = tk.Tk()
    root.title("Threading Example")
    root.geometry("340x180")

    result_queue = queue.Queue()
    progress = ttk.Progressbar(root, mode="determinate", maximum=100)
    progress.pack(fill="x", padx=20, pady=20)

    status_label = tk.Label(root, text="Idle")
    status_label.pack()

    def background_work():
        """Runs on a separate thread — never touch widgets directly here."""
        for i in range(1, 101):
            time.sleep(0.02)  # simulate work (I/O, computation, etc.)
            result_queue.put(i)
        result_queue.put("done")

    def start_task():
        start_button.config(state="disabled")
        status_label.config(text="Working...")
        threading.Thread(target=background_work, daemon=True).start()
        poll_queue()

    def poll_queue():
        """Runs on the GUI thread — safe to update widgets here."""
        try:
            while True:
                item = result_queue.get_nowait()
                if item == "done":
                    status_label.config(text="Finished")
                    start_button.config(state="normal")
                    return
                progress["value"] = item
        except queue.Empty:
            pass
        root.after(30, poll_queue)  # check again shortly

    start_button = tk.Button(root, text="Start Long Task", command=start_task)
    start_button.pack(pady=10)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 3 — Canvas animation loop
# ─────────────────────────────────────────────────────────────────────────
def example_3_canvas_animation():
    """
    A simple bouncing-ball animation using root.after() as the frame
    clock, instead of a blocking loop. This is the standard pattern for
    any Tkinter animation or game.
    """
    root = tk.Tk()
    root.title("Canvas Animation Example")

    WIDTH, HEIGHT = 400, 300
    canvas = tk.Canvas(root, width=WIDTH, height=HEIGHT, bg="#111")
    canvas.pack()

    radius = 15
    ball = canvas.create_oval(0, 0, radius * 2, radius * 2, fill="#ff5555", outline="")

    state = {"x": 100, "y": 80, "dx": 4, "dy": 3}

    def tick():
        state["x"] += state["dx"]
        state["y"] += state["dy"]

        if state["x"] <= 0 or state["x"] + radius * 2 >= WIDTH:
            state["dx"] *= -1
        if state["y"] <= 0 or state["y"] + radius * 2 >= HEIGHT:
            state["dy"] *= -1

        canvas.coords(ball, state["x"], state["y"], state["x"] + radius * 2, state["y"] + radius * 2)
        root.after(16, tick)  # roughly 60 frames per second

    tick()
    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 4 — Custom reusable widget (subclassing tk.Frame)
# ─────────────────────────────────────────────────────────────────────────
class LabeledSlider(tk.Frame):
    """
    A reusable compound widget: a label, a slider, and a live value
    display, packaged as one class. This is the standard way to build
    your own widgets on top of Tkinter's primitives.
    """

    def __init__(self, parent, text, from_=0, to=100, command=None, **kwargs):
        super().__init__(parent, **kwargs)
        self._command = command

        self.label = tk.Label(self, text=text, width=12, anchor="w")
        self.label.grid(row=0, column=0, padx=(0, 8))

        self.value_var = tk.IntVar(value=from_)
        self.scale = ttk.Scale(
            self, from_=from_, to=to, orient="horizontal",
            variable=self.value_var, command=self._on_change,
        )
        self.scale.grid(row=0, column=1, sticky="ew")

        self.value_label = tk.Label(self, textvariable=self.value_var, width=4)
        self.value_label.grid(row=0, column=2, padx=(8, 0))

        self.columnconfigure(1, weight=1)

    def _on_change(self, value):
        self.value_var.set(int(float(value)))
        if self._command:
            self._command(self.value_var.get())

    def get(self):
        return self.value_var.get()


def example_4_custom_widget():
    def on_color_change(_=None):
        r, g, b = red.get(), green.get(), blue.get()
        hex_color = f"#{r:02x}{g:02x}{b:02x}"
        preview.config(bg=hex_color)
        hex_label.config(text=hex_color)

    root = tk.Tk()
    root.title("Custom Widget Example — RGB Mixer")
    root.geometry("360x260")

    red = LabeledSlider(root, "Red", 0, 255, command=lambda v: on_color_change())
    green = LabeledSlider(root, "Green", 0, 255, command=lambda v: on_color_change())
    blue = LabeledSlider(root, "Blue", 0, 255, command=lambda v: on_color_change())

    for widget in (red, green, blue):
        widget.pack(fill="x", padx=20, pady=8)

    preview = tk.Frame(root, width=100, height=60, bg="#000000", relief="sunken", bd=1)
    preview.pack(pady=10)
    preview.pack_propagate(False)

    hex_label = tk.Label(root, text="#000000", font=("Courier", 11))
    hex_label.pack()

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 5 — Treeview: sortable, multi-column table
# ─────────────────────────────────────────────────────────────────────────
def example_5_treeview_table():
    """
    ttk.Treeview is Tkinter's built-in table/tree widget — used for file
    browsers, data grids, or any structured list with columns.
    """
    root = tk.Tk()
    root.title("Treeview Example — Data Table")
    root.geometry("480x300")

    columns = ("name", "role", "score")
    tree = ttk.Treeview(root, columns=columns, show="headings")

    for col, width in zip(columns, (160, 160, 100)):
        tree.heading(col, text=col.capitalize(), command=lambda c=col: sort_by(c, False))
        tree.column(col, width=width, anchor="center")

    data = [
        ("Alice Chen", "Engineer", 92),
        ("Marco Rossi", "Designer", 78),
        ("Sara Kim", "Analyst", 85),
        ("David Lee", "Engineer", 88),
        ("Priya Nair", "Manager", 95),
    ]
    for row in data:
        tree.insert("", tk.END, values=row)

    def sort_by(col, reverse):
        items = [(tree.set(k, col), k) for k in tree.get_children("")]
        try:
            items.sort(key=lambda t: float(t[0]), reverse=reverse)
        except ValueError:
            items.sort(reverse=reverse)
        for index, (_, k) in enumerate(items):
            tree.move(k, "", index)
        tree.heading(col, command=lambda: sort_by(col, not reverse))

    tree.pack(fill="both", expand=True, padx=10, pady=10)

    scrollbar = ttk.Scrollbar(root, orient="vertical", command=tree.yview)
    tree.configure(yscrollcommand=scrollbar.set)
    scrollbar.place(relx=1.0, rely=0, relheight=1.0, anchor="ne")

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 6 — Drag and drop between two lists (pure Tkinter, no extra library)
# ─────────────────────────────────────────────────────────────────────────
def example_6_drag_and_drop():
    """
    Tkinter has no built-in drag-and-drop API, so it is implemented
    manually with mouse-motion events: press to pick up, motion to drag
    a floating label, release to drop it onto a target.
    """
    root = tk.Tk()
    root.title("Drag and Drop Example")
    root.geometry("420x300")

    tk.Label(root, text="Drag items from the left list to the right list",
             font=("Arial", 10)).pack(pady=10)

    container = tk.Frame(root)
    container.pack(fill="both", expand=True, padx=20)

    source = tk.Listbox(container, exportselection=False)
    target = tk.Listbox(container, exportselection=False)
    source.pack(side="left", fill="both", expand=True, padx=(0, 10))
    target.pack(side="left", fill="both", expand=True)

    for item in ("Task A", "Task B", "Task C", "Task D"):
        source.insert(tk.END, item)

    drag_data = {"text": None, "widget": None}

    def on_start(event):
        widget = event.widget
        selection = widget.curselection()
        if not selection:
            return
        drag_data["text"] = widget.get(selection[0])
        drag_data["widget"] = widget

    def on_release(event):
        if drag_data["text"] is None:
            return
        drop_widget = root.winfo_containing(event.x_root, event.y_root)
        if drop_widget is target:
            target.insert(tk.END, drag_data["text"])
            index = source.get(0, tk.END).index(drag_data["text"])
            source.delete(index)
        drag_data["text"] = None

    source.bind("<ButtonPress-1>", on_start)
    source.bind("<ButtonRelease-1>", on_release)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 7 — Embedding a matplotlib chart (requires: pip install matplotlib)
# ─────────────────────────────────────────────────────────────────────────
def example_7_matplotlib_embed():
    """
    Tkinter has no charting widget of its own; matplotlib's Tk backend
    lets a full Figure be embedded directly inside a Tkinter window,
    including live updates.
    """
    from matplotlib.figure import Figure
    from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

    root = tk.Tk()
    root.title("Matplotlib Embedding Example")
    root.geometry("500x420")

    figure = Figure(figsize=(5, 3.5), dpi=100)
    plot = figure.add_subplot(111)
    x_data = list(range(20))
    y_data = [random.randint(10, 90) for _ in x_data]
    line, = plot.plot(x_data, y_data, color="#2d6cdf")
    plot.set_title("Live Random Data")

    canvas = FigureCanvasTkAgg(figure, master=root)
    canvas.get_tk_widget().pack(fill="both", expand=True, padx=10, pady=10)
    canvas.draw()

    def refresh_data():
        new_y = [random.randint(10, 90) for _ in x_data]
        line.set_ydata(new_y)
        plot.relim()
        plot.autoscale_view()
        canvas.draw()

    tk.Button(root, text="Refresh Data", command=refresh_data).pack(pady=5)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 8 — Full application: multi-tab Notebook with shared state (MVC-style)
# ─────────────────────────────────────────────────────────────────────────
class AppState:
    """Central data store shared across tabs — a minimal 'model' layer."""

    def __init__(self):
        self.items = []
        self._listeners = []

    def subscribe(self, callback):
        self._listeners.append(callback)

    def add_item(self, name, price):
        self.items.append({"name": name, "price": price})
        self._notify()

    def remove_item(self, index):
        if 0 <= index < len(self.items):
            del self.items[index]
            self._notify()

    def total(self):
        return sum(i["price"] for i in self.items)

    def _notify(self):
        for callback in self._listeners:
            callback()


class EntryTab(ttk.Frame):
    """Tab 1 — add new items to the shared state."""

    def __init__(self, parent, state: AppState):
        super().__init__(parent, padding=15)
        self.state = state

        ttk.Label(self, text="Item name:").grid(row=0, column=0, sticky="w", pady=4)
        self.name_entry = ttk.Entry(self, width=25)
        self.name_entry.grid(row=0, column=1, pady=4)

        ttk.Label(self, text="Price:").grid(row=1, column=0, sticky="w", pady=4)
        self.price_entry = ttk.Entry(self, width=25)
        self.price_entry.grid(row=1, column=1, pady=4)

        ttk.Button(self, text="Add Item", command=self._add).grid(row=2, column=0, columnspan=2, pady=10)

        self.status = ttk.Label(self, text="", foreground="green")
        self.status.grid(row=3, column=0, columnspan=2)

    def _add(self):
        name = self.name_entry.get().strip()
        try:
            price = float(self.price_entry.get())
        except ValueError:
            messagebox.showerror("Invalid Price", "Enter a valid number for price.")
            return
        if not name:
            messagebox.showwarning("Missing Name", "Enter an item name.")
            return

        self.state.add_item(name, price)
        self.status.config(text=f"Added '{name}'")
        self.name_entry.delete(0, tk.END)
        self.price_entry.delete(0, tk.END)


class SummaryTab(ttk.Frame):
    """Tab 2 — displays items from shared state; updates automatically."""

    def __init__(self, parent, state: AppState):
        super().__init__(parent, padding=15)
        self.state = state
        self.state.subscribe(self.refresh)

        self.tree = ttk.Treeview(self, columns=("name", "price"), show="headings", height=8)
        self.tree.heading("name", text="Item")
        self.tree.heading("price", text="Price")
        self.tree.column("name", width=200)
        self.tree.column("price", width=100, anchor="e")
        self.tree.pack(fill="both", expand=True)

        ttk.Button(self, text="Remove Selected", command=self._remove_selected).pack(pady=8)

        self.total_label = ttk.Label(self, text="Total: $0.00", font=("Arial", 12, "bold"))
        self.total_label.pack()

    def refresh(self):
        self.tree.delete(*self.tree.get_children())
        for item in self.state.items:
            self.tree.insert("", tk.END, values=(item["name"], f"${item['price']:.2f}"))
        self.total_label.config(text=f"Total: ${self.state.total():.2f}")

    def _remove_selected(self):
        selection = self.tree.selection()
        if not selection:
            return
        index = self.tree.index(selection[0])
        self.state.remove_item(index)


def example_8_full_app_notebook():
    """
    Ties everything together: a Notebook (tabbed interface) where each
    tab is its own class, sharing one central AppState so changes in one
    tab are reflected in the other automatically — a small but real
    example of separating data (model) from display (view).
    """
    root = tk.Tk()
    root.title("Advanced Example — Expense Tracker")
    root.geometry("420x420")

    style = ttk.Style()
    style.theme_use("clam")

    state = AppState()

    notebook = ttk.Notebook(root)
    notebook.pack(fill="both", expand=True, padx=10, pady=10)

    entry_tab = EntryTab(notebook, state)
    summary_tab = SummaryTab(notebook, state)

    notebook.add(entry_tab, text="Add Item")
    notebook.add(summary_tab, text="Summary")

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# Entry point — pick which example to run
# ─────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    # Change this to run a different example.
    # Note: example_7_matplotlib_embed requires `pip install matplotlib`.
    EXAMPLE = example_8_full_app_notebook

    EXAMPLE()

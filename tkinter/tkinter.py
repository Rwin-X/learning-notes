"""
Tkinter Examples Collection
============================
All examples from "Tkinter — A Minimal Learning Guide" in a single file.

Each example is wrapped in its own function. Only ONE example runs at a
time — pick it by setting EXAMPLE below, or just call the function you
want at the bottom of the file.

Run:
    python3 tkinter_examples.py
"""

import tkinter as tk
from tkinter import messagebox, filedialog


# ─────────────────────────────────────────────────────────────────────────
# 2.1 — Empty window
# ─────────────────────────────────────────────────────────────────────────
def example_2_1_empty_window():
    root = tk.Tk()
    root.title("My First App")
    root.geometry("400x300")

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 2.2 — A label inside the window
# ─────────────────────────────────────────────────────────────────────────
def example_2_2_label():
    root = tk.Tk()
    root.title("Hello Tkinter")

    label = tk.Label(root, text="Hello, Tkinter!", font=("Arial", 16))
    label.pack(pady=20)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 3.1 — Label with color and font
# ─────────────────────────────────────────────────────────────────────────
def example_3_1_label_styled():
    root = tk.Tk()
    root.title("Styled Label")

    label = tk.Label(root, text="Status: Ready", fg="green", font=("Arial", 12))
    label.pack(pady=20)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 3.2 — Button with a click handler
# ─────────────────────────────────────────────────────────────────────────
def example_3_2_button():
    def on_click():
        label.config(text="Button was clicked!")

    root = tk.Tk()
    root.title("Button Example")

    label = tk.Label(root, text="Waiting...", font=("Arial", 12))
    label.pack(pady=10)

    button = tk.Button(root, text="Click Me", command=on_click)
    button.pack(pady=10)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 3.3 — Entry: reading text input
# ─────────────────────────────────────────────────────────────────────────
def example_3_3_entry():
    def show_name():
        name = entry.get()
        result_label.config(text=f"Hello, {name}!")

    root = tk.Tk()
    root.title("Entry Example")

    entry = tk.Entry(root, width=25)
    entry.pack(pady=10)

    button = tk.Button(root, text="Greet", command=show_name)
    button.pack()

    result_label = tk.Label(root, text="")
    result_label.pack(pady=10)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 4.1 — pack(): side positioning
# ─────────────────────────────────────────────────────────────────────────
def example_4_1_pack():
    root = tk.Tk()
    root.title("Pack Example")
    root.geometry("300x200")

    tk.Label(root, text="Top").pack(side="top")
    tk.Label(root, text="Bottom").pack(side="bottom")
    tk.Label(root, text="Left").pack(side="left")
    tk.Label(root, text="Right").pack(side="right")

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 4.2 — grid(): a simple form
# ─────────────────────────────────────────────────────────────────────────
def example_4_2_grid_form():
    root = tk.Tk()
    root.title("Grid Example")

    tk.Label(root, text="Name:").grid(row=0, column=0, padx=5, pady=5, sticky="e")
    tk.Entry(root).grid(row=0, column=1, padx=5, pady=5)

    tk.Label(root, text="Email:").grid(row=1, column=0, padx=5, pady=5, sticky="e")
    tk.Entry(root).grid(row=1, column=1, padx=5, pady=5)

    tk.Button(root, text="Submit").grid(row=2, column=0, columnspan=2, pady=10)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 4.3 — place(): fixed positioning
# ─────────────────────────────────────────────────────────────────────────
def example_4_3_place():
    root = tk.Tk()
    root.title("Place Example")
    root.geometry("300x200")

    tk.Label(root, text="Fixed position").place(x=50, y=100)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 5.1 — Binding a key press
# ─────────────────────────────────────────────────────────────────────────
def example_5_1_key_binding():
    def on_key(event):
        print(f"Key pressed: {event.char}")

    root = tk.Tk()
    root.title("Key Binding Example")
    root.geometry("300x150")

    tk.Label(root, text="Type something (check the console)").pack(pady=20)
    root.bind("<KeyPress>", on_key)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 5.2 — Binding a mouse click
# ─────────────────────────────────────────────────────────────────────────
def example_5_2_mouse_binding():
    def on_click(event):
        print(f"Clicked at ({event.x}, {event.y})")

    root = tk.Tk()
    root.title("Mouse Binding Example")
    root.geometry("300x200")
    root.bind("<Button-1>", on_click)  # Button-1 = left mouse click

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 6.1 — Checkbutton
# ─────────────────────────────────────────────────────────────────────────
def example_6_1_checkbutton():
    def show_status():
        print("Checked:", agree.get())

    root = tk.Tk()
    root.title("Checkbutton Example")
    agree = tk.BooleanVar()

    check = tk.Checkbutton(root, text="I agree to the terms", variable=agree)
    check.pack(pady=10)

    tk.Button(root, text="Submit", command=show_status).pack()

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 6.2 — Radiobutton
# ─────────────────────────────────────────────────────────────────────────
def example_6_2_radiobutton():
    def show_choice():
        print("Selected:", choice.get())

    root = tk.Tk()
    root.title("Radiobutton Example")
    choice = tk.StringVar(value="small")

    for size in ("small", "medium", "large"):
        tk.Radiobutton(root, text=size.capitalize(), variable=choice, value=size).pack(anchor="w")

    tk.Button(root, text="Confirm", command=show_choice).pack(pady=10)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 6.3 — Listbox
# ─────────────────────────────────────────────────────────────────────────
def example_6_3_listbox():
    def show_selection():
        selected = listbox.get(listbox.curselection())
        print("You picked:", selected)

    root = tk.Tk()
    root.title("Listbox Example")

    listbox = tk.Listbox(root)
    listbox.pack(padx=10, pady=10)

    for item in ("Apple", "Banana", "Cherry"):
        listbox.insert(tk.END, item)

    tk.Button(root, text="Select", command=show_selection).pack()

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 7.1 — Frames: two sections in one window
# ─────────────────────────────────────────────────────────────────────────
def example_7_1_frames():
    root = tk.Tk()
    root.title("Frames Example")

    top_frame = tk.Frame(root, pady=10)
    top_frame.pack()

    bottom_frame = tk.Frame(root, pady=10)
    bottom_frame.pack()

    tk.Label(top_frame, text="Top Section", font=("Arial", 14)).pack()
    tk.Button(top_frame, text="Button A").pack(side="left", padx=5)
    tk.Button(top_frame, text="Button B").pack(side="left", padx=5)

    tk.Label(bottom_frame, text="Bottom Section", font=("Arial", 14)).pack()
    tk.Entry(bottom_frame).pack()

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 8.1 — Menu bar
# ─────────────────────────────────────────────────────────────────────────
def example_8_1_menu():
    def new_file():
        print("New file")

    root = tk.Tk()
    root.title("Menu Example")

    menu_bar = tk.Menu(root)
    root.config(menu=menu_bar)

    file_menu = tk.Menu(menu_bar, tearoff=0)
    file_menu.add_command(label="New", command=new_file)
    file_menu.add_separator()
    file_menu.add_command(label="Exit", command=root.quit)
    menu_bar.add_cascade(label="File", menu=file_menu)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 8.2 — Built-in dialogs: messagebox and filedialog
# ─────────────────────────────────────────────────────────────────────────
def example_8_2_dialogs():
    def show_info():
        messagebox.showinfo("Info", "Operation completed.")

    def confirm_action():
        if messagebox.askyesno("Confirm", "Are you sure?"):
            print("Confirmed")

    def open_file():
        path = filedialog.askopenfilename()
        print("Selected file:", path)

    root = tk.Tk()
    root.title("Dialogs Example")

    tk.Button(root, text="Show Info", command=show_info).pack(pady=5)
    tk.Button(root, text="Confirm", command=confirm_action).pack(pady=5)
    tk.Button(root, text="Open File", command=open_file).pack(pady=5)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 9.1 — Canvas: basic shapes
# ─────────────────────────────────────────────────────────────────────────
def example_9_1_canvas_shapes():
    root = tk.Tk()
    root.title("Canvas Shapes Example")

    canvas = tk.Canvas(root, width=300, height=200, bg="white")
    canvas.pack()

    canvas.create_rectangle(20, 20, 120, 100, fill="lightblue", outline="black")
    canvas.create_oval(150, 20, 250, 100, fill="lightgreen")
    canvas.create_line(20, 150, 280, 150, width=3, fill="red")
    canvas.create_text(150, 180, text="Canvas Drawing", font=("Arial", 10))

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 9.2 — Canvas: drawing on click
# ─────────────────────────────────────────────────────────────────────────
def example_9_2_canvas_draw_on_click():
    def draw_dot(event):
        r = 4
        canvas.create_oval(event.x - r, event.y - r, event.x + r, event.y + r, fill="black")

    root = tk.Tk()
    root.title("Draw on Click Example")

    canvas = tk.Canvas(root, width=300, height=200, bg="white")
    canvas.pack()
    canvas.bind("<Button-1>", draw_dot)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 10.1 — Variables: live text update with StringVar
# ─────────────────────────────────────────────────────────────────────────
def example_10_1_stringvar():
    root = tk.Tk()
    root.title("StringVar Example")
    message = tk.StringVar(value="Type something...")

    def update_label(*args):
        label.config(text=message.get())

    message.trace_add("write", update_label)

    entry = tk.Entry(root, textvariable=message)
    entry.pack(pady=10)

    label = tk.Label(root, text=message.get())
    label.pack()

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# 11.1 — Complete example: To-Do List app
# ─────────────────────────────────────────────────────────────────────────
def example_11_1_todo_app():
    def add_task():
        task = entry.get().strip()
        if task:
            listbox.insert(tk.END, task)
            entry.delete(0, tk.END)
        else:
            messagebox.showwarning("Empty Task", "Please type a task first.")

    def delete_task():
        selected = listbox.curselection()
        if selected:
            listbox.delete(selected)
        else:
            messagebox.showwarning("No Selection", "Select a task to delete.")

    root = tk.Tk()
    root.title("To-Do List")
    root.geometry("320x400")

    entry_frame = tk.Frame(root, pady=10)
    entry_frame.pack(fill="x")

    entry = tk.Entry(entry_frame, width=25)
    entry.pack(side="left", padx=5)

    add_button = tk.Button(entry_frame, text="Add", command=add_task)
    add_button.pack(side="left")

    listbox = tk.Listbox(root, width=40, height=15)
    listbox.pack(padx=10, pady=5)

    delete_button = tk.Button(root, text="Delete Selected", command=delete_task)
    delete_button.pack(pady=10)

    root.mainloop()


# ─────────────────────────────────────────────────────────────────────────
# Entry point — pick which example to run
# ─────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    # Change this to run a different example.
    EXAMPLE = example_9_1_canvas_shapes()
     

    EXAMPLE()

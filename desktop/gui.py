import tkinter as tk
from tkinter import ttk
from PIL import ImageTk
import logging

logger = logging.getLogger(__name__)

class PhoneRemoteGUI:
    def __init__(self, root, url: str):
        self.root = root
        self.root.title("PhoneRemote Server")
        self.root.geometry("400x600")
        self.root.resizable(False, False)
        self.root.configure(bg="#0a0a1a")

        # Styles
        style = ttk.Style()
        style.theme_use('default')
        style.configure('TFrame', background='#0a0a1a')
        style.configure('TLabel', background='#0a0a1a', foreground='#ffffff')

        # Main frame
        main_frame = ttk.Frame(root, padding="20 20 20 20")
        main_frame.pack(fill=tk.BOTH, expand=True)

        # Title
        title_label = ttk.Label(main_frame, text="PhoneRemote", font=("Helvetica", 24, "bold"), foreground="#7c3aed")
        title_label.pack(pady=(0, 5))
        
        subtitle_label = ttk.Label(main_frame, text="Escanea para conectar", font=("Helvetica", 12))
        subtitle_label.pack(pady=(0, 20))

        # QR Frame (placeholder until image is set)
        self.qr_label = tk.Label(main_frame, bg="#1a1a2e", width=40, height=15)
        self.qr_label.pack(pady=10)

        # URL Label
        self.url_label = ttk.Label(main_frame, text=url, font=("Courier", 9), foreground="#a78bfa", wraplength=360)
        self.url_label.pack(pady=(10, 5))

        # Copy URL Button
        self.copy_btn = tk.Button(
            main_frame, text="📋 Copiar URL", font=("Helvetica", 10),
            bg="#7c3aed", fg="white", relief="flat", cursor="hand2",
            activebackground="#6d28d9", activeforeground="white",
            command=lambda: self._copy_url(url)
        )
        self.copy_btn.pack(pady=(0, 10))

        # Status Frame
        status_frame = ttk.Frame(main_frame)
        status_frame.pack(fill=tk.X, pady=(20, 0))

        self.status_indicator = tk.Canvas(status_frame, width=15, height=15, bg="#0a0a1a", highlightthickness=0)
        self.status_indicator.pack(side=tk.LEFT, padx=(0, 10))
        self.status_circle = self.status_indicator.create_oval(2, 2, 13, 13, fill="#fbbf24", outline="")

        self.status_text = ttk.Label(status_frame, text="Esperando conexión...", font=("Helvetica", 11))
        self.status_text.pack(side=tk.LEFT)

    def set_qr_image(self, pil_image):
        """Display the PIL Image QR code."""
        # Resize to fit nicely
        pil_image = pil_image.resize((250, 250))
        self.qr_photo = ImageTk.PhotoImage(pil_image)
        self.qr_label.configure(image=self.qr_photo, width=250, height=250)

    def update_status(self, connected: bool, count: int):
        """Update connection status safely from another thread."""
        def _update():
            if connected and count > 0:
                self.status_indicator.itemconfig(self.status_circle, fill="#10b981") # Green
                self.status_text.configure(text=f"Conectado ({count} dispositivo{'s' if count > 1 else ''})")
            else:
                self.status_indicator.itemconfig(self.status_circle, fill="#fbbf24") # Yellow
                self.status_text.configure(text="Esperando conexión...")
                
        # thread-safe UI update
        self.root.after(0, _update)

    def _copy_url(self, url: str):
        """Copy the WebSocket URL to the clipboard."""
        self.root.clipboard_clear()
        self.root.clipboard_append(url)
        # Briefly change button text to show confirmation
        self.copy_btn.configure(text="✅ Copiado!")
        self.root.after(2000, lambda: self.copy_btn.configure(text="📋 Copiar URL"))

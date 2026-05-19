import os
import sys
import threading
import logging
import secrets
import tkinter as tk
import uvicorn

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("PhoneRemote")

from utils.network import get_local_ip, find_available_port
from utils.qr import generate_qr_image
from server import app, set_config
from gui import PhoneRemoteGUI

def ensure_firewall_rule(port: int):
    """Ensure Windows Firewall allows incoming connections on the given port."""
    import subprocess
    rule_name = f"PhoneRemote_TCP_{port}"
    try:
        # Check if rule already exists
        result = subprocess.run(
            ["netsh", "advfirewall", "firewall", "show", "rule", f"name={rule_name}"],
            capture_output=True, text=True, creationflags=subprocess.CREATE_NO_WINDOW
        )
        if "No rules match" in result.stdout or result.returncode != 0:
            # Create the rule
            logger.info(f"Creating firewall rule for port {port}...")
            subprocess.run(
                ["netsh", "advfirewall", "firewall", "add", "rule",
                 f"name={rule_name}", "dir=in", "action=allow",
                 "protocol=TCP", f"localport={port}"],
                capture_output=True, text=True, creationflags=subprocess.CREATE_NO_WINDOW
            )
            logger.info("Firewall rule created.")
        else:
            logger.info("Firewall rule already exists.")
    except Exception as e:
        logger.warning(f"Could not configure firewall (may need admin): {e}")

def run_server(port: int):
    """Run the Uvicorn ASGI server."""
    logger.info(f"Starting server on port {port}")
    # Run uvicorn programmatically
    # We use log_level="warning" to avoid spamming the console with every connection
    uvicorn.run(app, host="0.0.0.0", port=port, log_level="warning")

def main():
    logger.info("Starting PhoneRemote Desktop Server")
    
    # 1. Detect Network
    ip = get_local_ip()
    port = find_available_port(8888)
    
    # 2. Generate Security Token
    token = secrets.token_urlsafe(12)
    
    # 3. Create Connection URL
    url = f"ws://{ip}:{port}/ws/{token}"
    logger.info(f"Server URL: {url}")
    
    # 4. Generate QR Code
    logger.info("Generating QR code...")
    qr_img = generate_qr_image(url)
    
    # 5. Initialize GUI
    root = tk.Tk()
    gui = PhoneRemoteGUI(root, url)
    gui.set_qr_image(qr_img)
    
    # 6. Configure Server
    set_config(token, gui.update_status)
    
    # 6.5. Ensure firewall allows connections
    ensure_firewall_rule(port)
    
    # 7. Start Server in a background thread
    server_thread = threading.Thread(target=run_server, args=(port,), daemon=True)
    server_thread.start()
    
    # 8. Start GUI event loop (must be on main thread)
    logger.info("Server running. Close the window to stop.")
    root.protocol("WM_DELETE_WINDOW", root.destroy)
    root.mainloop()
    
    logger.info("Shutting down PhoneRemote")
    sys.exit(0)

if __name__ == "__main__":
    # If run from PyInstaller bundle, change CWD to the bundle directory
    if getattr(sys, 'frozen', False):
        os.chdir(sys._MEIPASS)
        
    main()

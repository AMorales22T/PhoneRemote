import logging
import json
import asyncio
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

from .controllers.mouse import MouseController
from .controllers.keyboard import KeyboardController
from .controllers.media import MediaController
from .controllers.system import SystemController

logger = logging.getLogger(__name__)

app = FastAPI(title="PhoneRemote Server")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Shared state
class ServerState:
    token: str = ""
    connected_clients: int = 0
    gui_update_callback = None

state = ServerState()

# Controllers
mouse_ctrl = MouseController()
keyboard_ctrl = KeyboardController()
media_ctrl = MediaController()
system_ctrl = SystemController()

def set_config(token: str, gui_callback):
    state.token = token
    state.gui_update_callback = gui_callback

@app.websocket("/ws/{client_token}")
async def websocket_endpoint(websocket: WebSocket, client_token: str):
    if client_token != state.token:
        logger.warning(f"Rejected connection with invalid token: {client_token}")
        await websocket.close(code=4003)
        return

    await websocket.accept()
    state.connected_clients += 1
    if state.gui_update_callback:
        state.gui_update_callback(True, state.connected_clients)
        
    logger.info(f"Client connected. Total clients: {state.connected_clients}")

    try:
        # Send initial status
        await websocket.send_json({
            "t": "status",
            "connected": True,
            "volume": media_ctrl.get_volume()
        })

        while True:
            data = await websocket.receive_text()
            try:
                msg = json.loads(data)
                cmd = msg.get("t")
                
                if cmd == "mm":
                    mouse_ctrl.move(msg.get("x", 0), msg.get("y", 0))
                elif cmd == "mc":
                    mouse_ctrl.click(msg.get("b", "left"))
                elif cmd == "md":
                    mouse_ctrl.double_click()
                elif cmd == "ms":
                    mouse_ctrl.scroll(msg.get("d", 0))
                elif cmd == "ds":
                    mouse_ctrl.drag_start()
                elif cmd == "de":
                    mouse_ctrl.drag_end()
                elif cmd == "kt":
                    keyboard_ctrl.type_text(msg.get("text", ""))
                elif cmd == "kp":
                    keyboard_ctrl.press_key(msg.get("key", ""))
                elif cmd == "kh":
                    keyboard_ctrl.hotkey(msg.get("keys", []))
                elif cmd == "mp":
                    media_ctrl.play_pause()
                elif cmd == "mn":
                    media_ctrl.next_track()
                elif cmd == "mb":
                    media_ctrl.prev_track()
                elif cmd == "vu":
                    media_ctrl.volume_up()
                    await websocket.send_json({"t": "status", "volume": media_ctrl.get_volume()})
                elif cmd == "vd":
                    media_ctrl.volume_down()
                    await websocket.send_json({"t": "status", "volume": media_ctrl.get_volume()})
                elif cmd == "vm":
                    media_ctrl.mute()
                elif cmd == "vl":
                    media_ctrl.set_volume(msg.get("v", 50))
                elif cmd == "fs":
                    media_ctrl.fullscreen()
                elif cmd == "oa":
                    system_ctrl.open_app(msg.get("app", ""))
                elif cmd == "sp":
                    system_ctrl.sleep_pc()
                elif cmd == "so":
                    system_ctrl.screen_off()
                elif cmd == "cg":
                    text = system_ctrl.clipboard_get()
                    await websocket.send_json({"t": "clipboard", "text": text})
                elif cmd == "cs":
                    system_ctrl.clipboard_set(msg.get("text", ""))
                    
            except json.JSONDecodeError:
                logger.error("Invalid JSON received")
            except Exception as e:
                logger.error(f"Error processing command: {e}")
                
    except WebSocketDisconnect:
        state.connected_clients -= 1
        logger.info(f"Client disconnected. Total clients: {state.connected_clients}")
        if state.gui_update_callback:
            state.gui_update_callback(state.connected_clients > 0, state.connected_clients)

import logging
from pynput.mouse import Controller, Button

logger = logging.getLogger(__name__)

class MouseController:
    def __init__(self):
        self.mouse = Controller()
        self.is_dragging = False

    def move(self, dx: float, dy: float):
        """Move the mouse relative to current position."""
        try:
            self.mouse.move(dx, dy)
        except Exception as e:
            logger.error(f"Error moving mouse: {e}")

    def click(self, button_name: str = 'left'):
        """Click the specified mouse button."""
        try:
            btn = Button.right if button_name == 'right' else Button.left
            self.mouse.click(btn, 1)
        except Exception as e:
            logger.error(f"Error clicking mouse: {e}")

    def double_click(self):
        """Double click the left mouse button."""
        try:
            self.mouse.click(Button.left, 2)
        except Exception as e:
            logger.error(f"Error double clicking mouse: {e}")

    def scroll(self, delta: float):
        """Scroll vertically."""
        try:
            # pynput scroll uses positive for up, negative for down
            self.mouse.scroll(0, delta)
        except Exception as e:
            logger.error(f"Error scrolling: {e}")

    def drag_start(self):
        """Press and hold the left mouse button."""
        try:
            if not self.is_dragging:
                self.mouse.press(Button.left)
                self.is_dragging = True
        except Exception as e:
            logger.error(f"Error starting drag: {e}")

    def drag_end(self):
        """Release the left mouse button."""
        try:
            if self.is_dragging:
                self.mouse.release(Button.left)
                self.is_dragging = False
        except Exception as e:
            logger.error(f"Error ending drag: {e}")

import socket
import logging

logger = logging.getLogger(__name__)

def get_local_ip() -> str:
    """Detect local IP on the network by connecting to a public DNS server."""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        # 8.8.8.8 is Google's public DNS. No actual connection is made for UDP,
        # but the OS determines the right local IP to reach that destination.
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception as e:
        logger.warning(f"Failed to detect local IP using UDP socket trick: {e}")
        # Fallback
        try:
            return socket.gethostbyname(socket.gethostname())
        except Exception:
            return "127.0.0.1"

def find_available_port(preferred: int = 8888) -> int:
    """Find an available port, starting with the preferred one."""
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.bind(("", preferred))
        s.close()
        return preferred
    except OSError:
        pass
    
    # Let OS pick a free port
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(("", 0))
    port = s.getsockname()[1]
    s.close()
    return port

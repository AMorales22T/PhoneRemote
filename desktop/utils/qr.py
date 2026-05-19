import qrcode
import base64
import io
from PIL import Image

def generate_qr_image(url: str) -> Image.Image:
    """Generate a PIL Image of a QR code containing the URL."""
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(url)
    qr.make(fit=True)
    
    # Create an image with dark purple on white background
    img = qr.make_image(fill_color="#1a1a2e", back_color="white")
    return img

def generate_qr_base64(url: str) -> str:
    """Generate a base64 encoded PNG string of the QR code."""
    img = generate_qr_image(url)
    buffer = io.BytesIO()
    img.save(buffer, format="PNG")
    img_str = base64.b64encode(buffer.getvalue()).decode("utf-8")
    return f"data:image/png;base64,{img_str}"

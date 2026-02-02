from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
from PIL import Image, UnidentifiedImageError
import io

try:
    import pillow_heif
    pillow_heif.register_heif_opener()
except ImportError:
    pass  

@csrf_exempt
def convert_file(request):
    if request.method == "POST":
        if "file" not in request.FILES:
            return JsonResponse({"error": "Dosya bulunamadı"}, status=400)

        file = request.FILES["file"]

        try:
            img = Image.open(file)
        except UnidentifiedImageError:
            return JsonResponse({"error": "Görsel formatı desteklenmiyor veya bozuk dosya"}, status=400)

        img = img.convert("L")  

        temp = io.BytesIO()
        
        format = img.format if img.format in ["JPEG", "PNG", "BMP", "GIF", "TIFF", "WEBP"] else "PNG"
        img.save(temp, format=format)
        temp.seek(0)

        response = HttpResponse(temp, content_type=f"image/{format.lower()}")
        response["Content-Disposition"] = f'inline; filename="grayscale.{format.lower()}"'
        return response

    return JsonResponse({"error": "Sadece POST kabul edilir"}, status=405)


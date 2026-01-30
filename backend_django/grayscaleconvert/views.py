from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
from PIL import Image
import io


@csrf_exempt
def convert_file(request):
    if request.method == "POST":
        if "file" not in request.FILES:
            return JsonResponse({"error": "Dosya bulunamadı"}, status=400)

        file = request.FILES["file"]


        img = Image.open(file)
        img = img.convert("L")  

        temp = io.BytesIO()
        img.save(temp, format="PNG")
        temp.seek(0)

        response = HttpResponse(temp, content_type="image/png")
        response["Content-Disposition"] = 'inline; filename="grayscale.png"'
        return response

    return JsonResponse({"error": "Sadece POST kabul edilir"}, status=405)


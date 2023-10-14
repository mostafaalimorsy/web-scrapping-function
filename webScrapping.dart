final TextEditingController urlTextController = TextEditingController();
final TextEditingController titleTextController = TextEditingController();
final TextEditingController descriptionTextController = TextEditingController();
var itemPictureUrls = <String?>[].obs;

RxInt imageIndex = 0.obs;
/*
  there are 3 status:
  0: it is normal one :: that mean user go for add new wish item page
  1: that mean loading
  2:that mean success or failed
  
   */
RxInt getDataFromLinkStatus = 0.obs;
Rx<bool> isgetDataFromLinkSuccess = Rx(false);

Future<Map> getTitleDescriptionImage(String url) async {
  getDataFromLinkStatus.value = 1;
  try {
    // Make a request to the URL.
    final Uri _url = Uri.parse('${url}');
    var response = await http.get(_url);

    // Parse the HTML response.
    var document = parse(response.body);

    // Extract the title, description, and image from the HTML response.
    var title = document.querySelector('title')!.text;

    var description = document.querySelector('meta[name="description"]')?.attributes['content'];
    var img = document.querySelectorAll('img');
    var imageUrls = <String?>[].obs;
    for (var image in img) {
      if (image.attributes['src']!.isURL) {
        if (image.attributes['src']!.endsWith('.svg') || image.attributes['src']!.endsWith('.gif')) {
        } else {
          if (image.attributes['alt'] != null) {
            if (image.attributes['alt']!.isNotEmpty) {
              imageUrls.add(image.attributes['src']);
            }
          }
        }
      }
    }

    final maxLength = 50; // Define the maximum length of the title
    final truncatedTitle = title.length > maxLength ? '${title.substring(0, maxLength)}...' : title;
    if (title != null || title != "") {
      titleTextController.text = truncatedTitle;
      if (description == "" || description == null) {
        descriptionTextController.text = title;
      } else {
        descriptionTextController.text = description;
      }
    }

    itemPictureUrls.value = imageUrls.value;
    isgetDataFromLinkSuccess.value = true;
    getDataFromLinkStatus.value = 2;
    Future.delayed(Duration(seconds: 2), () {
      getDataFromLinkStatus.value = 0;
    });

    // Return a map with the title, description, and image as the keys.
    return {'title': truncatedTitle, 'description': description!, "img": imageUrls};
  } catch (e) {
    isgetDataFromLinkSuccess.value = false;

    getDataFromLinkStatus.value = 2;
    Future.delayed(Duration(seconds: 2), () {
      getDataFromLinkStatus.value = 0;
    });

    return {'title': e, 'description': e, "img": e};
  }
}

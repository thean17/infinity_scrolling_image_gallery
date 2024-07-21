# infinity_scrolling_image_gallery

Features
- display images from picsum.photos in a ListView
- images are cached using CachedNetworkImage to ensure smooth loading when scrolling up or down the ListView
- click on image to expand to fullscreen view
- support infinity scroll by loading images on demand when scrolling towards the end of the ListView
- support pull to refresh
- each image has an option button on top right corner to allow sharing of selected image's URL via a share sheet 
  and also saving of selected image into phone's gallery

Tested on these following OS versions
- Android 14

Instruction to run the app
* Run 'flutter run --release' in the project directory to start the application in release profile.

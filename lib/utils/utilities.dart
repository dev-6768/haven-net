import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Utilities {
  static String processBullyPrompt(String prompt) {
    return "classify the following text into a bully text in yes or no : $prompt also state what effect do such words put on the victims mind in a single paragraph.";
  }

  static String processLegalReprecussionsPrompt(String prompt) {
    return '''state the legal reprecussions which the bully might have to face in extreme cases if he bullies the child in the following way : $prompt
    Also classify in which categor(y)(ies) would you place this bully incident out of those mentioned below - 
    "School Punishment",
    "Harassment",
    "Hate Crime",
    "Battery",
    "Assault",
    "Physical Harm",
    "Cyberbullying",
    "Kidnapping",
    "Abuse",
    "Child Labor",
    "Child Trafficking",
    "Child Begging",

    State the categories explicitly in the last line of the prompt answer with categories as comma separated values. also, state the categories as it is without any altercation in its case or spelling.
    ''';
  }

  static String processPromptForSupportChat(String message) {
    return '''Now listen to me very carefully as this is an alarming situation.
    The prompt which you are going to see below is from either a parent or his/her child who is a victim of some sort of child abuse or child bully.
    He might be in or out of danger, going through a mental trauma and he is either in dilemma as to who to consult in this hostile environment.
    They look up to you so you could give them some meaningful insight into this matter. The prompt is stated on the very next line.

    Now the prompt goes : $message
    ''';
  }

  Future<String> getFullLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return "NA";
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return "NA";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return "NA";
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Reverse geocode to get detailed location info
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Get location details
        String street = place.street ?? "N/A";  // Street name
        String streetNumber = place.subThoroughfare ?? "N/A";  // Street number
        String landmark = place.name ?? "N/A";  // Nearby landmark
        String city = place.locality ?? "N/A";  // City name
        String country = place.country ?? "N/A";  // Country name

        return "$landmark, $street $streetNumber, $city, $country";
      } 
      
      else {
        return "NA";
      }
    } 
    
    catch (e) {
      return "NA"; // Return NA if any error occurs
    }
  }

}

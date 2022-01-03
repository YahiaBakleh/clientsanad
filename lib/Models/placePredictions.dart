class PlacePredictions {
String place_id='';
String main_text='';
String secondary_text='';

  PlacePredictions({required this.place_id,required this.main_text,required this.secondary_text});
  PlacePredictions.formJson(Map<String , dynamic> json){
    place_id=json['place_id'];
    main_text=json['structured_formatting']['main_text'];
    secondary_text=json['structured_formatting']['secondary_text'];

  }
}
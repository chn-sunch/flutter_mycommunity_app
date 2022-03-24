

abstract class PostEvent {
  String locationCode = "";

  PostEvent({
    required this.locationCode,
  });

  @override
  List<Object> get props => [locationCode];
}

class PostFetched extends PostEvent {

  PostFetched(String locationCode): super(locationCode: locationCode);
}

class Refreshed extends PostEvent {
  Refreshed(String locationCode): super(locationCode: locationCode);
}
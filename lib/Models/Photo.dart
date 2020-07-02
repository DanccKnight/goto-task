class Photo {
  User user;
  Url url;
  Link downloadLink;

  Photo({this.user,this.url,this.downloadLink});

  factory Photo.fromJson(Map<String,dynamic> json){
    return Photo(
      user: User.fromJson(json['user']),
      url: Url.fromJson(json['urls']),
      downloadLink: Link.fromJson(json['links'])
    );
  }
}

class User {
  String id;
  String name;
  String username;

  User({this.id,this.name,this.username});

  factory User.fromJson(Map<String,dynamic> json){
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username']
    );
  }
}

class Url {
  String raw;
  String full;
  String regular;
  String thumbnail;
  String small;

  Url({this.raw,this.full,this.regular,this.thumbnail,this.small});

  factory Url.fromJson(Map<String,dynamic> json){
    return Url(
      raw: json['raw'],
      full: json['full'],
      regular: json['regular'],
      thumbnail: json['thumbnail'],
      small: json['small']
    );
  }
}

class Link {
  String download;
  String downloadLocation;

  Link({this.download,this.downloadLocation});

  factory Link.fromJson(Map<String,dynamic> json){
    return Link(
      download: json['download'],
      downloadLocation: json['download_location']
    );
  }
}
class Task {
  final int id;
  final String title;
  final String description;
  final DateTime dateTime;

  Task({required this.id,required this.title, required this.description, required this.dateTime});
    factory Task.fromMap(Map<String, dynamic> json) => Task(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        dateTime: json["dateTime"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "description": description,
        "dateTime": dateTime
      };
}
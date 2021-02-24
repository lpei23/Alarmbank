class History {
  int id;
  DateTime date;
  int timeExceeded;
  int penalty;

  History({
    this.id,
    this.date,
    this.timeExceeded,
    this.penalty,
  });

  factory History.fromMap(Map<String, dynamic> json) => History(
    id: json["id"],
    date: DateTime.parse(json["date"]),
    timeExceeded: json["timeExceeded"],
    penalty: json["penalty"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "date": date.toIso8601String(),
    "timeExceeded": timeExceeded,
    "penalty": penalty,
  };
}
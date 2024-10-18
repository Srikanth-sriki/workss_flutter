import 'dart:convert';

List<FaqModelList> faqModelListFromJson(List<dynamic> data) =>
    List<FaqModelList>.from(data.map((x) => FaqModelList.fromJson(x)));

String faqModelListToJson(List<FaqModelList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FaqModelList {
  String? id;
  String? faqId;
  String? question;
  String? answer;

  FaqModelList({
    this.id,
    this.faqId,
    this.question,
    this.answer,
  });

  factory FaqModelList.fromJson(Map<String, dynamic> json) => FaqModelList(
    id: json.containsKey('id') ? json["id"]?.toString() ?? "" : "",
    faqId: json.containsKey('faq_id') ? json["faq_id"]?.toString() ?? "" : "",
    question: json.containsKey('question') ? json["question"]?.toString() ?? "" : "",
    answer: json.containsKey('answer') ? json["answer"]?.toString() ?? "" : "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "faq_id": faqId,
    "question": question,
    "answer": answer,
  };
}

final partsOfSpeech = {
  "V": "Verb",
  "N": "Noun",
  "Adv": "Adverb",
  "Adj": "Adjective",
  "Art": "Article",
  "DPro": "Demonstrative Pronoun",
  "IPro": "Interrogative / Indefinite Pronoun",
  "PPro": "Personal / Possessive Pronoun",
  "RecPro": "Reciprocal Pronoun",
  "RelPro": "Relative Pronoun",
  "RefPro": "Reflexive Pronoun",
  "Prep": "Preposition",
  "Conj": "Conjunction",
  "I": "Interjection",
  "Prtcl": "Particle",
  "IntPrtcl": "Interrogative Particle",
  "Heb": "Hebrew Word",
  "Aram": "Aramaic Word",
  "Indec": "Indeclinable",
};

final person = {
  "1": "1st Person",
  "2": "2nd Person",
  "3": "3rd Person",
};

final tense = {
  "P": "Present",
  "I": "Imperfect",
  "F": "Future",
  "A": "Aorist",
  "R": "Perfect",
  "L": "Pluperfect",
};

final mood = {
  "I": "Indicative",
  "M": "Imperative",
  "S": "Subjunctive",
  "O": "Optative",
  "N": "Infinitive",
  "P": "Participle",
};

final voice = {
  "A": "Active",
  "M": "Middle",
  "P": "Passive",
  "M/P": "Middle or Passive",
};

final wordCase = {
  "N": "Nominative",
  "V": "Vocative",
  "A": "Accusative",
  "G": "Genitive",
  "D": "Dative",
};

final number = {
  "S": "Singular",
  "P": "Plural",
};

final gender = {
  "M": "Masculine",
  "F": "Feminine",
  "N": "Neuter",
};

final comparison = {
  "C": "Comparative",
  "S": "Superlative",
};

String codeToWord(String code) {
  // print(code);
  // TODO "Make sure you've got all the types of words."
  List<String?> parts = [];
  switch (code.split("-")) {
    case [String part]:
      {
        parts.add(partsOfSpeech[part]);
      }
    case [String part, String details]:
      {
        parts.add(partsOfSpeech[part]);
        if (part == "V") {
          parts.add(tense[details[0]]);
          parts.add(mood[details[1]]);
          parts.add(voice[details[2]]);
        } else if (part == "Adv") {
          parts.add(comparison[details[0]]);
        } else {
          parts.add(wordCase[details[0]]);
          if (int.tryParse(details[1]) != null) {
            parts.add(person[details[1]]);
            parts.add(number[details[2]]);
          } else if (int.tryParse(details[2]) != null) {
            parts.add(gender[details[1]]);
            parts.add(person[details[2]]);
            parts.add(number[details[3]]);
          } else {
            parts.add(gender[details[1]]);
            parts.add(number[details[2]]);
          }
        }
      }
    case [String part, String details, String details2]:
      {
        parts.add(partsOfSpeech[part]);
        if (part == "Adj") {
          // Comparative Adjective
          parts.add(wordCase[details[0]]);
          parts.add(gender[details[1]]);
          parts.add(number[details[2]]);
          parts.add(comparison[details2[0]]);
        }

        if (part == "V") {
          // Verb
          // Details One
          if (details == "M") {
            parts.add(mood[details[0]]);
            parts.add(person[details2[0]]);
            parts.add(number[details2[1]]);
          } else {
            parts.add(tense[details[0]]);
            parts.add(mood[details[1]]);
            if (details.length > 2) {
              parts.add(voice[details.substring(2)]);
            }

            //  Details Two
            if (details2.length == 3) {
              // participle
              parts.add(wordCase[details2[0]]);
              parts.add(gender[details2[1]]);
              parts.add(number[details2[2]]);
            } else {
              parts.add(person[details2[0]]);
              parts.add(number[details2[1]]);
            }
          }
        }
      }
  }
  if (parts.contains(null)) {
    throw "Invalid word $parts";
  }

  final smallcode = code
      .split("-")
      .sublist(1)
      .fold<String>("", (previousValue, element) => previousValue + element)
      .replaceAll("M/P", "P");

  if (code.split("-").length > 1 && smallcode.length != parts.length - 1) {
    throw "Parts are missing $smallcode $code $parts";
  }

  return parts.fold("", (previousValue, element) => "$previousValue$element ");
}

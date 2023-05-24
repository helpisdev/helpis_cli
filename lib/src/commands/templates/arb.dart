String arbTemplate(final String locale, final String name) => '''
{
  "@@locale" : "$locale",
  "appName" : "$name",
  "key" : "Value",
  "@key" : {
      "description" : "Documentation comments value description."
  },
  "anotherKey" : "anotherValue",
  "@anotherKey" : {},
  "keyWithParameter" : "Value with {parameter}",
  "@keyWithParameter" : {
      "description" : "Value with parameter description.",
      "placeholders": {
          "parameter": {
              "type": "String"
          }
      }
  },
  "keyWithPlural" : "{count, plural, zero{You have no new messages} one{You have 1 new message} other{You have {count} new messages}}",
  "@keyWithPlural" : {
      "description" : "Key with a value that can be zero, singular, or plural.",
      "placeholders": {
          "count": {
              "type": "int"
           }
      }
  },
  "keyWithDoubleAndDateTypes" : "Your balance is {amount} on {date}.\\nThis adds a new line.",
  "@keyWithDoubleAndDateTypes" : {
      "description": "Parameters of double and date types with all available parameters for the specific format.",
      "placeholders": {
          "amount": {
              "type": "double",
              "format": "currency",
              "example": "\$1000.00",
              "description": "Account balance",
              "optionalParameters": {
                  "decimalDigits": 2,
                  "name": "USD",
                  "symbol": "\$",
                  "customPattern": "¤#0.00"
              }
          },
          "date": {
              "type": "DateTime",
              "format": "yMd",
              "example": "11/10/2021",
              "description": "Balance date"
          }
      }
  },
  "keyWithSelect": "{sex, select, male{His birthday} female{Her birthday} other{His/Her birthday}}",
  "@keyWithSelect": {
      "description": "Selects a value from available enum types or default (other).",
      "placeholders": {
          "sex": {
              "type": "String"
          }
      }
  }
}
''';

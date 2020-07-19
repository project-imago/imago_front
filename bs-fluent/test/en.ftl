# Simple comment

### File comment

## Grouping comment

# Message comment
simple-message = Simple message
-simple-term = Simple term

message-with-variable = Message: Variable is {$foo}
-term-with-variable = Term: Variable is {$foo}

## Grouping comment

message-with-simple-number-variable = Message: Variable is {NUMBER($foo)}
-term-with-simple-number-variable = Term: Variable is {NUMBER($foo)}

message-with-number-variable = Message: Variable is {NUMBER($foo, minimumIntegerDigits: 3)}
-term-with-number-variable = Term: Variable is {NUMBER($foo, minimumIntegerDigits: 3)}

message-with-datetime-variable = Message: Variable is {DATETIME($foo, weekday: "long")}
-term-with-datetime-variable = Term: Variable is {DATETIME($foo, weekday: "long")}


message-with-an = Message: Something
    .attribute = Message: Attribute
    .attribute-with-variable = Message: Attribute: Variable is {$foo}
-term-with-an = Term: Something
    .attribute = Term: Attribute
    .simple-attribute = simple_attribute
    .attribute-with-variable = Term: Attribute: Variable is {$foo}
    .simple-attribute-with-variable = simple_attribute_with_{$foo}

message-with-message-reference = Message: Message is {simple-message}
-term-with-message-reference = Term: Message is {simple-message}

message-with-term-reference = Message: Term is {-simple-term}
-term-with-term-reference = Term: Term is {-simple-term}


message-with-message-attribute-reference = Message: Message attribute is {message-with-an.attribute}
-term-with-message-attribute-reference = Term: Message attribute is {message-with-an.attribute}

message-with-parameterized-term-reference = Message: Term is {-term-with-variable(foo: "bar")}
-term-with-parameterized-term-reference = Term: Term is {-term-with-variable(foo: "bar")}

message-with-number-parameterized-term-reference = Message: Term is {-term-with-number-variable(foo: 6)}
-term-with-number-parameterized-term-reference = Term: Term is {-term-with-number-variable(foo: 6)}

message-with-special-char = Message: opening curly brace: {"{"}.
-term-with-special-char = Term: opening curly brace: {"{"}.



message-with-selector-expecting-text =
    { $case ->
       *[nominative] Nominative
        [locative] Locative
    }

message-with-selector-expecting-number =
    { NUMBER($count) ->
       [one] One
       [3] 3
       [3.14] Almost PI
       ["weird"] Weird
       *[other] Other
    }

message-with-selector-expecting-number-as-ordinal =
    { NUMBER($pos, type: "ordinal") ->
       [1] first!
       [one] {$pos}st
       [two] {$pos}nd
       [few] {$pos}rd
      *[other] {$pos}th
    }

message-with-selector-expecting-term-attribute =
    { -term-with-an.simple-attribute ->
       [simple_attribute] Match
      *[other] No match
    }

message-with-selector-expecting-term-attribute-with-variable =
    { -term-with-an.attribute-with-variable(foo: "bar") ->
       [simple_attribute_with_bar] Match
      *[other] No match
    }

message-with-selector-having-references-in-variants =
    { $case ->
       *[nominative] Nominative: Variable is {$foo}, message is ${simple-message}
        [locative] Locative: Variable is {$foo}, term is ${-simple-term}
        [other] Other: term with variable is ${-term-with-variable(foo: "bar")}
    }

message-with-nested-selectors =
    { $case ->
       *[nominative] Nominative { $count ->
            [one] -> One
           *[other] -> Other
            }
        [locative] Locative
    }
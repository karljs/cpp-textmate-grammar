require_relative './readable_grammar.rb'

cpp_grammar = Grammar.new(
    name:"C++",
    scope_name: "source.cpp",
    version: "https://github.com/jeff-hykin/cpp-textmate-grammar/blob/master/generate.rb",
    information_for_contributors: [
        "This code was auto generated by a much-more-readble ruby file: https://github.com/jeff-hykin/cpp-textmate-grammar/blob/master/generate.rb",
        "It is a lot easier to modify the ruby file and have it generate the rest of the code",
        "Also the ruby source is very open to merge requests, so please make one if something could be improved",
        "This file essentially an updated/improved fork of the atom syntax https://github.com/atom/language-c/blob/master/grammars/c%2B%2B.cson",
    ],
)


characters_in_template_call = /[\s<>,\w]/
template_call_innards_pattern = newPattern(
    repository_name: 'template_call_innards'
    match: /</.zeroOrMoreOf(characters_in_template_call).then(/>/).maybe(@spaces),
    tag_as: "meta.template.call",
    patterns: [
        :'storage_types-c',
        :constants,
        :scope_resolution,
        newPattern(
            match: variable_name,
            tag_as: "storage.type.user-defined",
        ),
        :operators,
        :'numbers-c',
        :strings,
        newPattern(
            match: /,/,
            tag_as: "punctuation.separator.comma.template.argument",
        ),
    ]
)
template_definition_range = Range.new(
    tag_as: "template.definition",
    start_pattern:  lookBehindToAvoid(@standard_character).then(
            match: /template/,
            tag_as: "storage.type.template",
        ).maybe(@spaces).then(
            match: /</,
            tag_as: "punctuation.section.angle-brackets.start.template.definition"
        ),
    end_pattern: newPattern( match: />/, tag_as:  "punctuation.section.angle-brackets.end.template.definition" )
    includes: [ :scope_resolution, :template_definition_argument, :template_call_innards ]
)


unit_tag_name = "keyword.other.unit"
tick_mark_pattern = newPattern(repository_name: :tick_mark_pattern, match: /'/, tag_as: "punctuation.separator.constant.numeric")
hex_binary_or_octal_pattern = newPattern(
    repository_name: :hex_binary_or_octal,
    # octal, hexadecimal, or binary start
    match: newPattern(
            match: /0/.lookAheadToAvoid(/[\.eE]/).maybe(/[xXbB]/),
            tag_as: unit_tag_name
        # octal, hexadecimal, or binary contents
        ).then(
            match: /[0-9a-fA-F\.']+/,
            includes: [ tick_mark_pattern ]
        ).maybe(
            # hexadecimal_floating_constant start
            newPattern(
                match: /p/.or(/P/),
                tag_as: unit_tag_name
            ).maybe(
                newPattern(
                    match: /\+/,
                    tag_as: "keyword.operator.plus.exponent.hexadecimal-floating-point-literal",
                ).or(
                    match: /\-/,
                    tag_as: "keyword.operator.minus.exponent.hexadecimal-floating-point-literal",
                )
            # hexadecimal_floating_constant contents
            ).then(
                match: /[0-9']++/,
                includes: [ tick_mark_pattern ]
            )
        )
)

literal_suffix = newPattern(
    hex_binary_or_octal_pattern.or(
        # decimal/base-10 start 
        newPattern(
            match: /[0-9\.][0-9\.']*/,
            includes: [ tick_mark_pattern ]
        ).maybe(
            # scientific notation
            newPattern(
                match: /[eE]/,
                tag_as: unit_tag_name,
            ).maybe(
                # plus or minus symbols
                newPattern(
                    match: /\+/,
                    tag_as: "keyword.operator.plus.exponent",
                ).or(
                    match: /\-/,
                    tag_as: "keyword.operator.minus.exponent",
                )
            # exponent of scientific notation
            ).then(
                match: /[0-9']++/,
                includes: [ tick_mark_pattern ]
            )
        )
    )
# check if number is a custom literal
).then(
    match: zeroOrMoreOf(/[_a-zA-Z]/),
    tag_as: unit_tag_name
)

puts cpp_grammar.to_h.to_json
# puts hex_binary_or_octal_pattern.to_tag.to_json
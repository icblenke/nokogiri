module Nokogiri
module CSS
class GeneratedTokenizer < GeneratedParser

macro
  nl        \n|\r\n|\r|\f
  w         [\s\r\n\f]*
  nonascii  [^\\\\0-\\\\177]
  num       -?([0-9]+|[0-9]*\.[0-9]+)
  unicode   \\\\\\\\\[0-9A-Fa-f]{1,6}(\r\n|[\s\n\r\t\f])?

  escape    {unicode}|\\\\\\\[^\n\r\f0-9A-Fa-f]
  nmchar    [_A-Za-z0-9-]|{nonascii}|{escape}
  nmstart   [_A-Za-z]|{nonascii}|{escape}
  ident     [-]?({nmstart})({nmchar})*
  name      ({nmchar})+
  string1   "([^\n\r\f"]|\\{nl}|{nonascii}|{escape})*"
  string2   '([^\n\r\f']|\\{nl}|{nonascii}|{escape})*'
  string    {string1}|{string2}
  Comment   \/\*(.|[\r\n])*?\*\/

rule

# [:state]  pattern  [actions]

            {w}~={w}         { [:INCLUDES, text] }
            {w}\|={w}        { [:DASHMATCH, text] }
            {w}\^={w}        { [:PREFIXMATCH, text] }
            {w}\$={w}        { [:SUFFIXMATCH, text] }
            {w}\*={w}        { [:SUBSTRINGMATCH, text] }
            {w}!={w}         { [:NOT_EQUAL, text] }
            {w}={w}          { [:EQUAL, text] }
            {w}\){w}         { [:RPAREN, text] }
            {w}\[{w}         { [:LSQUARE, text] }
            {w}\]{w}         { [:RSQUARE, text] }
            {ident}\(\s*     { [:FUNCTION, text] }
            @{ident}         { [:IDENT, text] }
            {ident}          { [:IDENT, text] }
            {num}            { [:NUMBER, text] }
            \#{name}         { [:HASH, text] }
            {w}\+{w}         { [:PLUS, text] }
            {w}>{w}          { [:GREATER, text] }
            {w},{w}          { [:COMMA, text] }
            {w}~{w}          { [:TILDE, text] }
            \:not\({w}       { [:NOT, text] }
            @{ident}         { [:ATKEYWORD, text] }
            {num}%           { [:PERCENTAGE, text] }
            {num}{ident}     { [:DIMENSION, text] }
            <!--             { [:CDO, text] }
            -->              { [:CDC, text] }
            {w}\/\/{w}       { [:DOUBLESLASH, text] }
            {w}\/{w}         { [:SLASH, text] }
            
            U\+[0-9a-f?]{1,6}(-[0-9a-f]{1,6})?  {[:UNICODE_RANGE, text] }
            
            {Comment}                    /* ignore comments */
            [\s\t\r\n\f]+    { [:S, text] }
            [\.*:\[\]=\)]    { [text, text] }
            {string}         { [:STRING, text] }
            .                { [text, text] }
end
end
end

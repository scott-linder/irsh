#!/usr/bin/env python3

"""A lexical analyzer class for simple shell-like syntaxes."""

# Module and documentation by Eric S. Raymond, 21 Dec 1998
# Input stacking and error message cleanup added by ESR, March 2000
# push_source() and pop_source() made explicit by ESR, January 2001.
# Posix compliance, split(), string arguments, and
# iterator interface by Gustavo Niemeyer, April 2003.
# changes to tokenize more like Posix shells by Vinay Sajip, July 2016.

# Summary of changes required by PSF license:
# Ripped most things out. Return more context with the returned tokens to make
# it possible to distinguish e.g. literal punctuation from punctuation which
# was escaped or quoted. Changes by Scott Linder, December 2020.

import sys
import string
from collections import deque
from io import StringIO

__all__ = ["Token", "Lexer", "split"]

EOF = None
PUNCTUATION = '<>;|'
QUOTES = '\'"'
ESCAPE = '\\'
ESCAPED_QUOTES = '"'

class Token(str):
  def __new__(cls, word, quoted, escaped):
    obj = str.__new__(cls, word)
    obj.__quoted = quoted
    obj.__escaped = escaped
    return obj

  def __repr__(self):
      return 'Token({}, {}, {})'.format(self,
                                        repr(self.quoted),
                                        repr(self.escaped))

  @property
  def quoted(self):
      return self.__quoted

  @property
  def escaped(self):
      return self.__escaped

  def literal(self):
      if not self.quoted and not self.escaped:
          return self
      else:
          return None

class Lexer:
    "A lexical analyzer class for a simple shell-like syntax."
    def __init__(self, instream):
        if isinstance(instream, str):
            self.instream = StringIO(instream)
        else:
            self.instream = instream
        self.debug = 0
        self.state = ' '
        self.token = ''
        self.pushback_chars = deque()

    def _read_token(self):
        quoted = False
        escaped = False
        escapedstate = ' '
        while True:
            if self.pushback_chars:
                ch = self.pushback_chars.pop()
            else:
                ch = self.instream.read(1)
            if self.debug >= 3:
                print("Lexer: state=%r ch=%r" % (self.state, ch))
            if self.state is EOF:
                self.token = ''
                break
            elif self.state == ' ':
                if not ch:
                    self.state = EOF
                    break
                elif ch in string.whitespace:
                    if self.debug >= 2:
                        print("Lexer: I see whitespace in whitespace state")
                    if self.token or quoted:
                        break
                    else:
                        continue
                elif ch in ESCAPE:
                    escapedstate = 'a'
                    self.state = ch
                elif ch in PUNCTUATION:
                    self.token = ch
                    self.state = 'c'
                elif ch in QUOTES:
                    self.state = ch
                else:
                    self.token = ch
                    self.state = 'a'
            elif self.state in QUOTES:
                quoted = True
                if not ch:
                    if self.debug >= 2:
                        print("Lexer: I see EOF in quotes state")
                    raise ValueError("No closing quotation")
                if ch == self.state:
                    self.state = 'a'
                elif (ch in ESCAPE and self.state
                      in ESCAPED_QUOTES):
                    escapedstate = self.state
                    self.state = ch
                else:
                    self.token += ch
            elif self.state in ESCAPE:
                escaped = True
                if not ch:
                    if self.debug >= 2:
                        print("Lexer: I see EOF in escape state")
                    raise ValueError("No escaped character")
                # In posix shells, only the quote itself or the escape
                # character may be escaped within quotes.
                if (escapedstate in QUOTES and
                        ch != self.state and ch != escapedstate):
                    self.token += self.state
                self.token += ch
                self.state = escapedstate
            elif self.state in ('a', 'c'):
                if not ch:
                    self.state = EOF
                    break
                elif ch in string.whitespace:
                    if self.debug >= 2:
                        print("Lexer: I see whitespace in word state")
                    self.state = ' '
                    if self.token or quoted:
                        break
                    else:
                        continue
                elif self.state == 'c':
                    if ch in PUNCTUATION:
                        self.token += ch
                    else:
                        if ch not in string.whitespace:
                            self.pushback_chars.append(ch)
                        self.state = ' '
                        break
                elif ch in QUOTES:
                    self.state = ch
                elif ch in ESCAPE:
                    escapedstate = 'a'
                    self.state = ch
                elif ch not in PUNCTUATION:
                    self.token += ch
                else:
                    self.pushback_chars.append(ch)
                    if self.debug >= 2:
                        print("Lexer: I see punctuation in word state")
                    self.state = ' '
                    if self.token or quoted:
                        break
                    else:
                        continue
        result = self.token
        self.token = ''
        if not quoted and result == '':
            return EOF
        return Token(result, quoted, escaped)

    def __iter__(self):
        return self

    def __next__(self):
        token = self._read_token()
        if self.debug >= 1:
            print("Lexer: token=" + repr(token))
        if token == EOF:
            raise StopIteration
        return token

def split(s):
    """Split the string *s* using shell-like syntax."""
    return list(Lexer(s))

if __name__ == '__main__':
    lex = Lexer(sys.stdin)
    lex.debug = 3
    print(list(lex))

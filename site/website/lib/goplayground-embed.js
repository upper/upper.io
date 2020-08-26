/* MIT License
Copyright (c) 2017 Brad Howes
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

// Based on https://github.com/KaTeX/KaTeX/blob/master/website/lib/remarkable-katex.js

const Entities = require('html-entities').XmlEntities;

const entities = new Entities();

module.exports = function(md, options) {
    /**
     * Parse '$$' as a block. Based off of similar method in remarkable.
     */
		const parse = (state, startLine, endLine) => {
        let len;
        let params;
        let nextLine;
        let mem;
        let haveEndMarker = false;
        let pos = state.bMarks[startLine] + state.tShift[startLine];
        let max = state.eMarks[startLine];
        const dollar = 0x24;

        if (pos + 1 > max) { return false; }

        const marker = state.src.charCodeAt(pos);
        if (marker !== dollar) { return false; }

        // scan marker length
        mem = pos;
        pos = state.skipChars(pos, marker);
        len = pos - mem;

        if (len !== 2)  { return false; }

        // search end of block
        nextLine = startLine;

        for (;;) {
            ++nextLine;
            if (nextLine >= endLine) {
                // unclosed block should be autoclosed by end of document.
                // also block seems to be autoclosed by end of parent
                break;
            }

            pos = mem = state.bMarks[nextLine] + state.tShift[nextLine];
            max = state.eMarks[nextLine];

            if (pos < max && state.tShift[nextLine] < state.blkIndent) {
                // non-empty line with negative indent should stop the list:
                // - ```
                //  test
                break;
            }

            if (state.src.charCodeAt(pos) !== dollar) { continue; }

            if (state.tShift[nextLine] - state.blkIndent >= 4) {

                // closing fence should be indented less than 4 spaces
                continue;
            }

            pos = state.skipChars(pos, marker);

            // closing code fence must be at least as long as the opening one
            if (pos - mem < len) { continue; }

            // make sure tail has spaces only
            pos = state.skipSpaces(pos);

            if (pos < max) { continue; }

            haveEndMarker = true;

            // found!
            break;
        }

        // If a fence has heading spaces, they should be removed from
        // its inner block
        len = state.tShift[startLine];

        state.line = nextLine + (haveEndMarker ? 1 : 0);

        const code = state.getLines(startLine + 1, nextLine, len, true)
                        .trim();

				const content = '<textarea data-expanded="1" data-title="Toggle snippet" class="go-playground-snippet">' + entities.encode(code) + '</textarea>';

        state.tokens.push({
            type: 'goplayground',
            params,
            content,
            lines: [startLine, state.line],
            level: state.level,
            block: true,
        });

        return true;
    }

    md.block.ruler.before('code', 'goplayground', parse, options);

    md.renderer.rules.goplayground = function(tokens, idx) {
      return tokens[idx].content;
    };
};

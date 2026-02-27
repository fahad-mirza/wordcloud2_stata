*! wordcloud2 v1.2.0
*! Word cloud generator with collision detection (AABB + Archimedean spiral)
*! Inspired by amueller/word_cloud (Python). Outputs an interactive HTML/SVG file.
*! 
*!
*! Author: Fahad Mirza
*! Editor: Claude
*!
*!
*! Syntax:
*!   wordcloud2, textvar(varname) [options]
*!
*! Options:
*!   textvar(varname)     	String variable containing text              		(required)
*!   maxwords(#)          	Max words to display                         		[100]
*!   minfreq(#)           	Minimum word frequency to include            		[2]
*!   minlength(#)         	Minimum word character length                		[3]
*!   stopwords(string)    	Space-delimited extra stopwords to remove
*!   nostopwords          	Skip built-in English stopword removal
*!   noclean              	Skip lowercasing and punctuation removal
*!   title(string)        Chart title with optional color() and size() sub-options
*!                        title("My Cloud", color(#ff0000) size(2em))
*!                        title("My Cloud", color(rgb(0,128,255)) size(1.5em))
*!   width(#)             	Canvas width in pixels                        		[900]
*!   height(#)            	Canvas height in pixels                       		[500]
*!   margin(#)            	Padding between words in pixels               		[6]
*!   maxfontsize(#)       	Font size of most-frequent word               		[80]
*!   minfontsize(#)       	Font size of least-frequent word              		[10]
*!   savefile(string)     	Output HTML file path                         		["wordcloud2.html"]
*!   export(string)      	Export to a different format (Static)         		[png, jpg, jpeg, svg]
*!   bgcolor(string)      Background color — same format as title color()     [#16213e]
*!                        bgcolor(#16213e)  bgcolor(white)  bgcolor(rgb(0,30,60))
*!   palette(string)     	Color palette name from Ben Jann's colorpalette
*!                       	e.g. palette(Set1) palette(tableau) palette(viridis)
*!                       	Requires: ssc install palettes; ssc install colrspace
*!                       	Falls back to built-in tab10 if not installed / not specified

capture program drop wordcloud2
program define wordcloud2
    version 15.0

    syntax , TEXTvar(varname string)    ///
        [                               ///
        MAXWords(integer 100)           ///
        MINFreq(integer 2)              ///
        MINLength(integer 3)            ///
        STOPWords(string)               ///
        NOSTOPwords                     ///
        NOCLean                         ///
        TItle(string)                   ///
        Width(integer 900)              ///
        Height(integer 500)             ///
        MARgin(integer 6)               ///
        MAXFontsize(integer 80)         ///
        MINFontsize(integer 10)         ///
        SAVEFile(string)                ///
        EXPort(string)                  ///
        BGColor(string)                 ///
        PALette(string)                 ///
        ]

    // ── Defaults ─────────────────────────────────────────────────────────────
    // ── Parse title() ────────────────────────────────────────────────────────
    //
    // CONSISTENT COLOR FORMAT — bgcolor and title color() both use bare CSS:
    //   bgcolor(#16213e)              title("My Title", color(#16213e))
    //   bgcolor(white)                title("My Title", color(white))
    //   bgcolor(rgb(0,30,60))         title("My Title", color(rgb(0,128,255)))
    //
    // No quotes needed around the color value in either case.
    //
    // title() sub-options (order does not matter):
    //   title("My Title")
    //   title("My Title", color(#ff0000))
    //   title("My Title", size(2em))
    //   title("My Title", color(white) size(24px))
    //   title("My Title", color(rgb(0,128,255)) size(2em))
    //   title("My Title", size(1.5rem) color(rgb(0,128,255)))
    //
    if "`title'"  == "" local title "Word Cloud"

    // Step 1: split on first comma — left = title text, right = sub-options
    local _tcomma = strpos(`"`title'"', ",")
    if `_tcomma' > 0 {
        local title_text = strtrim(substr(`"`title'"', 1, `_tcomma' - 1))
        local _topts     = strtrim(substr(`"`title'"', `_tcomma' + 1, .))
    }
    else {
        local title_text = `"`title'"'
        local _topts     = ""
    }

    // Step 2a: extract color() — regex handles hex, named, rgb(), rgba(), hsl()
    // rgba?/hsla? branches capture nested parens; fallback handles simple values.
    local title_color = "#eeeeee"
    if regexm(`"`_topts'"', "color\((rgba?[^)]+\)|hsla?[^)]+\)|[^)]+)\)") {
        local title_color = strtrim(regexs(1))
    }

    // Step 2b: extract size()
    local title_size = "1.4em"
    if regexm(`"`_topts'"', "size\(([^)]+)\)") {
        local _rawsize = strtrim(regexs(1))
        if regexm(`"`_rawsize'"', "^[0-9]+(\.[0-9]+)?$") {
            local title_size = "`_rawsize'em"
        }
        else {
            local title_size = `"`_rawsize'"'
        }
    }

    // Validate title_color
    local _tc1 = substr(`"`title_color'"', 1, 1)
    if "`_tc1'" != "#" & !regexm(`"`title_color'"', "^[a-zA-Z]") {
        di as error "wordcloud2: title color() is not a valid CSS color: `title_color'"
        di as error "  Use: color(#ff0000)  color(white)  color(rgb(0,128,255))"
        exit 198
    }

    // Validate title_size
    if !regexm(`"`title_size'"', "[0-9]") {
        di as error "wordcloud2: title size() is not a valid CSS size: `title_size'"
        di as error "  Use: size(2em)  size(24px)  size(1.5rem)  size(120%)"
        exit 198
    }

    if `"`savefile'"' == "" local savefile "wordcloud2.html"

    // Validate export()
    local export_fmt = lower("`export'")
    if `"`export_fmt'"' != "" & `"`export_fmt'"' != "png" & ///
       `"`export_fmt'"' != "jpg" & `"`export_fmt'"' != "jpeg" & ///
       `"`export_fmt'"' != "svg" {
        di as error "wordcloud2: export() must be png, jpg, jpeg, or svg"
        exit 198
    }
    if `"`export_fmt'"' == "jpeg" local export_fmt "jpg"

    // ── Background colour ─────────────────────────────────────────────────────
    // Same bare CSS format as title color() — no quotes needed:
    //   bgcolor(#16213e)   bgcolor(white)   bgcolor(rgb(0,30,60))
    if `"`bgcolor'"'  == "" local bgcolor "#16213e"
    local bgcolor = strtrim(`"`bgcolor'"')
    local _bg1 = substr(`"`bgcolor'"', 1, 1)
    if "`_bg1'" != "#" & !regexm(`"`bgcolor'"', "^[a-zA-Z]") {
        di as error "wordcloud2: bgcolor() is not a valid CSS color: `bgcolor'"
        di as error "  Use: bgcolor(#16213e)  bgcolor(white)  bgcolor(rgb(0,30,60))"
        exit 198
    }




    // ── Preserve caller's data ────────────────────────────────────────────────
    preserve

    // =========================================================================
    // STEP 1 — Pull text variable, concatenate all rows into one string
    // =========================================================================
    quietly {
        keep `textvar'
        rename `textvar' _wc_raw

        // Concatenate every observation's text into a single master string
        // stored in observation 1. Done in Mata to avoid macro length limits.
        mata: wc_concat_rows("_wc_raw")

        keep in 1
        rename _wc_raw _wc_text
    }

    // =========================================================================
    // STEP 2 — Clean text (unless noclean specified)
    // =========================================================================
    if "`noclean'" == "" {
        quietly {
            replace _wc_text = lower(_wc_text)
            // Remove anything that is not a-z or space (mirrors Python [^a-z ])
            replace _wc_text = ustrregexra(_wc_text, "[^a-z ]", " ")
            // Collapse runs of whitespace
            replace _wc_text = ustrregexra(_wc_text, "\s+", " ")
            replace _wc_text = strtrim(_wc_text)
        }
    }

    // =========================================================================
    // STEP 3 — Tokenize: split master string into one word per observation
    //          Done in Mata using tokens() to avoid split/reshape naming limits
    // =========================================================================
    quietly {
        mata: wc_tokenize("_wc_text")
        rename _wc_text word
    }

    // =========================================================================
    // STEP 4 — Stopword removal
    // =========================================================================
    // Built-in list mirrors amueller/word_cloud STOPWORDS (apostrophes stripped
    // to match our punctuation-cleaned text)
    if "`nostopwords'" == "" {
        local builtin_sw ///
            a about above after again against all am an and any are arent as at ///
            be because been before being below between both but by cant cannot ///
            could couldnt did didnt do does doesnt doing dont down during each ///
            few for from further get got had hadnt has hasnt have havent having ///
            he hed hell hes her here heres hers herself him himself his how hows ///
            id ill im ive if in into is isnt it its itself lets me more most ///
            mustnt my myself no nor not of off on once only or other ought our ///
            ours ourselves out over own same shant she shed shell shes should ///
            shouldnt so some such than that thats the their theirs them themselves ///
            then there theres these they theyd theyll theyre theyve this those ///
            through to too under until up very was wasnt we wed well were weve ///
            werent what whats when whens where wheres which while who whos whom ///
            why whys will with wont would wouldnt you youd youll youre youve ///
            your yours yourself yourselves

        local all_sw `builtin_sw' `stopwords'
    }
    else {
        local all_sw `stopwords'
    }

    // Build a pipe-delimited regex alternation for efficient batch removal
    if `"`all_sw'"' != "" {
        local sw_pat ""
        foreach sw of local all_sw {
            if `"`sw_pat'"' == "" local sw_pat "`sw'"
            else                   local sw_pat "`sw_pat'|`sw'"
        }
        quietly drop if ustrregexm(word, "^(`sw_pat')$")
    }

    // Drop words shorter than minlength and any blanks
    quietly drop if length(word) < `minlength'
    quietly drop if missing(word) | word == ""

    // =========================================================================
    // STEP 5 — Count frequencies, filter, cap at maxwords
    // =========================================================================
    quietly {
        contract word, freq(freq)
        drop if freq < `minfreq'
        gsort -freq
        count
        if r(N) > `maxwords' keep in 1/`maxwords'
    }

    local nwords = _N
    if `nwords' == 0 {
        di as error "wordcloud2: no words remain after filtering."
        di as error "Try reducing minfreq() or minlength()."
        restore
        exit 198
    }

    di as text "wordcloud2: `nwords' unique words — computing layout..."

    // =========================================================================
    // STEP 6 — Font sizing  (mirrors relative_scaling = 0.5 in Python)
    //   font_size proportional to sqrt(freq), linearly mapped to
    //   [minfontsize, maxfontsize]
    // =========================================================================
    quietly {
        gen double _fsq = sqrt(freq)
        summarize _fsq, meanonly
        local fmin = r(min)
        local fmax = r(max)
        if `fmax' == `fmin' {
            gen int fontsize = `maxfontsize'
        }
        else {
            gen int fontsize = round(`minfontsize' + ///
                (`maxfontsize' - `minfontsize') * (_fsq - `fmin') / (`fmax' - `fmin'))
        }
        drop _fsq
    }

    // =========================================================================
    // STEP 7 — Bounding boxes
    //   bw ≈ fontsize × 0.6 × nchars  (DroidSansMono character aspect ratio)
    //   bh ≈ fontsize × 1.2            (cap-height + descender)
    //   Both padded by margin on each side
    // =========================================================================
    quietly {
        gen int    bw     = round(fontsize * 0.6 * length(word)) + `margin'
        gen int    bh     = round(fontsize * 1.2)                + `margin'
        gen double px     = .
        gen double py     = .
        gen byte   placed = 0
    }

    // =========================================================================
    // STEP 8 — Collision detection: AABB + Archimedean spiral (Mata)
    //   Mirrors the query_integral_image + spiral loop in wordcloud.py
    // =========================================================================
    mata: wc_place_words(`width', `height', `margin', `nwords')

    quietly {
        count if placed == 1
        local nplaced = r(N)
        keep if placed == 1
    }

    di as text "wordcloud2: `nplaced' of `nwords' words placed."

    // =========================================================================
    // STEP 9 — Assign word colors
    //   If palette() is specified, use Ben Jann's colorpalette command to get
    //   exactly nwords colors from the named palette. colorpalette automatically
    //   interpolates or cycles the palette to the requested n().
    //   Returns r(p1)..r(pN) as "R G B" Stata RGB triplets; we convert each
    //   to CSS rgb(R,G,B) using a Mata helper (wc_rgb_to_css).
    //   Falls back to built-in tab10 hex colors if:
    //     (a) palette() not specified, or
    //     (b) colorpalette not installed (capture absorbs the error)
    // =========================================================================
    quietly gen strL color = ""

    local _use_palette = 0
    if `"`palette'"' != "" {
        // Check colorpalette is installed
        capture which colorpalette
        if _rc != 0 {
            di as text "wordcloud2: colorpalette not found — install with:"
            di as text "  ssc install palettes"
            di as text "  ssc install colrspace"
            di as text "Falling back to built-in tab10 palette."
        }
        else {
            // Call colorpalette with exactly nwords colors, suppress graph
            capture colorpalette `palette', n(`nplaced') nograph
            if _rc != 0 {
                di as text `"wordcloud2: colorpalette failed for palette "`palette'" (rc=`_rc')"'
                di as text "Check the palette name. Falling back to built-in tab10 palette."
            }
            else {
                local _use_palette = 1
                di as text `"wordcloud2: using colorpalette "`palette'" (`nplaced' colors)"'
            }
        }
    }

    if `_use_palette' {
        // Convert each r(pN) from "R G B" to css "rgb(R,G,B)" and store in color var
        forvalues _ci = 1/`nplaced' {
            local _rgb = r(p`_ci')
            // Convert "R G B" → "rgb(R,G,B)" via token substitution
            local _r   = word("`_rgb'", 1)
            local _g   = word("`_rgb'", 2)
            local _b   = word("`_rgb'", 3)
            quietly replace color = "rgb(`_r',`_g',`_b')" in `_ci'
        }
    }
    else {
        // Built-in tab10 palette (Tableau-style, visually balanced on dark bg)
        local c1  "#4e79a7"
        local c2  "#f28e2b"
        local c3  "#e15759"
        local c4  "#76b7b2"
        local c5  "#59a14f"
        local c6  "#edc948"
        local c7  "#b07aa1"
        local c8  "#ff9da7"
        local c9  "#9c755f"
        local c10 "#bab0ac"
        forvalues _ci = 1/`=_N' {
            local _mod = mod(`_ci' - 1, 10) + 1
            quietly replace color = "`c`_mod''" in `_ci'
        }
    }

    // =========================================================================
    // STEP 10 — Write HTML / SVG output
    // =========================================================================
    capture file close _wcf
    file open _wcf using `"`savefile'"', write replace text

    // ── Head ──────────────────────────────────────────────────────────────────
    file write _wcf `"<!DOCTYPE html>"' _n
    file write _wcf `"<html lang='en'><head>"' _n
    file write _wcf `"<meta charset='UTF-8'>"' _n
    file write _wcf `"<title>`title_text'</title>"' _n
    file write _wcf `"<style>"' _n
    file write _wcf `"  body{margin:0;background:`bgcolor';display:flex;flex-direction:column;"' _n
    file write _wcf `"       align-items:center;font-family:'Segoe UI',Arial,sans-serif;color:#eee}"' _n
    file write _wcf `"  h1{margin:20px 0 8px;font-size:`title_size';letter-spacing:2px}"' _n
    file write _wcf `"  svg{border-radius:12px;box-shadow:0 8px 32px rgba(0,0,0,.5)}"' _n
    file write _wcf `"  .w{cursor:default;transition:opacity .15s}"' _n
    file write _wcf `"  .w:hover{opacity:.6}"' _n
    file write _wcf `"  #tt{position:fixed;background:rgba(0,0,0,.82);color:#fff;"' _n
    file write _wcf `"       padding:5px 11px;border-radius:5px;font-size:13px;"' _n
    file write _wcf `"       pointer-events:none;display:none;z-index:9}"' _n
    file write _wcf `"  footer{margin:10px 0 18px;font-size:11px;opacity:.4}"' _n
    file write _wcf `"</style></head><body>"' _n
    file write _wcf `"<h1 style='color:`title_color';font-size:`title_size''>`title_text'</h1>"' _n
    file write _wcf `"<div id='tt'></div>"' _n
    file write _wcf `"<svg width='`width'' height='`height'' viewBox='0 0 `width' `height''"' _n
    file write _wcf `"     xmlns='http://www.w3.org/2000/svg'>"' _n
    file write _wcf `"<rect width='`width'' height='`height'' fill='`bgcolor'' rx='12'/>"' _n

    // ── One <text> element per placed word ────────────────────────────────────
    // freq is a Stata integer stored as double. We must convert to a clean
    // integer string before writing into HTML attributes.
    // strtrim(string(x,"%12.0f")) removes the leading spaces that %12.0f adds,
    // giving "3" not "           3" — which is what was corrupting the tooltip.
    local nobs = _N
    forvalues i = 1/`nobs' {
        local w   = word[`i']
        local col = color[`i']

        // strtrim removes leading spaces from fixed-width format string
        local fr = strtrim(string(freq[`i'],     "%12.0f"))
        local fs = strtrim(string(fontsize[`i'], "%12.0f"))
        local tx = strtrim(string(round(px[`i'] + bw[`i'] / 2,         0.1), "%12.1f"))
        local ty = strtrim(string(round(py[`i'] + bh[`i'] - `margin', 0.1), "%12.1f"))

        // data-word  → el.dataset.word   (HTML spec camelCase)
        // data-count → el.dataset.count
        file write _wcf `"<text class='w' x='`tx'' y='`ty''"'  _n
        file write _wcf `"      font-size='`fs'' font-family='Arial,Helvetica,sans-serif'"'  _n
        file write _wcf `"      font-weight='bold' fill='`col'' text-anchor='middle'"'  _n
        file write _wcf `"      data-word='`w'' data-count='`fr''>`w'</text>"' _n
    }

    // ── Footer + tooltip JS + optional export button + close ──────────────────
    file write _wcf `"</svg>"' _n

    // Export button — rendered only when export() option is specified
    if `"`export_fmt'"' != "" {
        // Derive output filename: same stem as savefile, different extension
        // e.g. "results/cloud.html" → "results/cloud.png"
        local stem = ustrregexra(`"`savefile'"', `"\.html?$"', "")
        local imgname "`stem'.`export_fmt'"

        file write _wcf `"<div style='margin:10px 0 4px'>"' _n

        if "`export_fmt'" == "svg" {
            // SVG export: serialise the SVG element directly to a Blob and download
            file write _wcf `"<button id='expbtn' onclick='exportSVG()'"' _n
            file write _wcf `"  style='padding:8px 20px;border:none;border-radius:6px;"' _n
            file write _wcf `"         background:#4e79a7;color:#fff;font-size:14px;"' _n
            file write _wcf `"         cursor:pointer'>&#11015; Save as SVG</button>"' _n
        }
        else {
            // PNG / JPG export: draw SVG onto a Canvas then toDataURL
            file write _wcf `"<button id='expbtn' onclick='exportRaster()'"' _n
            file write _wcf `"  style='padding:8px 20px;border:none;border-radius:6px;"' _n
            file write _wcf `"         background:#4e79a7;color:#fff;font-size:14px;"' _n
            file write _wcf `"         cursor:pointer'>&#11015; Save as `fmt_upper'</button>"' _n
        }

        file write _wcf `"</div>"' _n
    }

    file write _wcf `"<footer>wordcloud2.ado &nbsp;·&nbsp; `nplaced' words</footer>"' _n
    file write _wcf `"<script>"' _n

    // ── Tooltip: reads data-word and data-count attributes ───────────────────
    // data-word → dataset.word   data-count → dataset.count  (HTML spec)
    file write _wcf `"const tt=document.getElementById('tt');"' _n
    file write _wcf `"document.querySelectorAll('.w').forEach(el=>{"' _n
    file write _wcf `"  el.addEventListener('mousemove',ev=>{"' _n
    file write _wcf `"    tt.style.display='block';"' _n
    file write _wcf `"    tt.style.left=(ev.clientX+14)+'px';"' _n
    file write _wcf `"    tt.style.top=(ev.clientY-28)+'px';"' _n
    file write _wcf `"    tt.textContent=el.dataset.word+': count = '+el.dataset.count;"' _n
    file write _wcf `"  });"' _n
    file write _wcf `"  el.addEventListener('mouseleave',()=>tt.style.display='none');"' _n
    file write _wcf `"});"' _n

    // ── Export functions ──────────────────────────────────────────────────────
    if `"`export_fmt'"' != "" {

        local stem = ustrregexra(`"`savefile'"', `"\.html?$"', "")
        local imgname "`stem'.`export_fmt'"

        if "`export_fmt'" == "svg" {
            // Serialise SVG → Blob → object URL → <a> click
            file write _wcf `"function exportSVG(){"' _n
            file write _wcf `"  const svg=document.querySelector('svg');"' _n
            file write _wcf `"  const xml=new XMLSerializer().serializeToString(svg);"' _n
            file write _wcf `"  const blob=new Blob([xml],{type:'image/svg+xml'});"' _n
            file write _wcf `"  const url=URL.createObjectURL(blob);"' _n
            file write _wcf `"  const a=document.createElement('a');"' _n
            file write _wcf `"  a.href=url; a.download='`imgname''; a.click();"' _n
            file write _wcf `"  URL.revokeObjectURL(url);"' _n
            file write _wcf `"}"' _n
        }
        else {
            // Raster export (PNG or JPG):
            //   1. Serialise SVG to a data URI
            //   2. Draw onto an offscreen Canvas via an Image element
            //   3. canvas.toDataURL() → download link
            // Background colour is filled first so JPG has no transparent pixels.
            local mime "image/png"
            if "`export_fmt'" == "jpg" local mime "image/jpeg"
            // Pre-compute uppercase label — avoids embedding upper("...") inside
            // a backtick-doublequote file write string, which causes the inner
            // double-quote to prematurely terminate the string literal, producing
            // broken JS that silently fails when the button is clicked.
            local fmt_upper = upper("`export_fmt'")



            file write _wcf `"function exportRaster(){"' _n
            file write _wcf `"  const btn=document.getElementById('expbtn');"' _n
            file write _wcf `"  btn.textContent='Rendering...';"' _n
            file write _wcf `"  btn.disabled=true;"' _n
            file write _wcf `"  const svg=document.querySelector('svg');"' _n
            file write _wcf `"  const W=parseInt(svg.getAttribute('width'));"' _n
            file write _wcf `"  const H=parseInt(svg.getAttribute('height'));"' _n
            file write _wcf `"  const xml=new XMLSerializer().serializeToString(svg);"' _n
            // Use TextEncoder to get UTF-8 bytes, then convert to base64 via
            // String.fromCharCode on chunks — avoids btoa() ASCII limit AND
            // avoids blob URL tainted-canvas security block (file:// context)
            file write _wcf `"  const bytes=new TextEncoder().encode(xml);"' _n
            file write _wcf `"  let bin='';"' _n
            file write _wcf `"  const chunk=8192;"' _n
            file write _wcf `"  for(let i=0;i<bytes.length;i+=chunk){"' _n
            file write _wcf `"    bin+=String.fromCharCode(...bytes.subarray(i,i+chunk));"' _n
            file write _wcf `"  }"' _n
            file write _wcf `"  const b64=btoa(bin);"' _n
            file write _wcf `"  const dataUri='data:image/svg+xml;base64,'+b64;"' _n
            file write _wcf `"  const canvas=document.createElement('canvas');"' _n
            file write _wcf `"  canvas.width=W; canvas.height=H;"' _n
            file write _wcf `"  const ctx=canvas.getContext('2d');"' _n
            file write _wcf `"  ctx.fillStyle='`bgcolor'';"' _n
            file write _wcf `"  const fmtLabel='`fmt_upper'';"' _n
            file write _wcf `"  const img=new Image();"' _n
            file write _wcf `"  img.onload=function(){"' _n
            file write _wcf `"    ctx.drawImage(img,0,0);"' _n
            file write _wcf `"    const imgUrl=canvas.toDataURL('`mime'',0.95);"' _n
            file write _wcf `"    const a=document.createElement('a');"' _n
            file write _wcf `"    a.href=imgUrl; a.download='`imgname'';"' _n
            file write _wcf `"    document.body.appendChild(a); a.click(); document.body.removeChild(a);"' _n
            file write _wcf `"    btn.textContent=String.fromCharCode(11015)+' Save as '+fmtLabel;"' _n
            file write _wcf `"    btn.disabled=false;"' _n
            file write _wcf `"  };"' _n
            file write _wcf `"  img.onerror=function(e){"' _n
            file write _wcf `"    console.error('SVG render failed',e);"' _n
            file write _wcf `"    btn.textContent='Export failed — see console';"' _n
            file write _wcf `"    btn.disabled=false;"' _n
            file write _wcf `"  };"' _n
            file write _wcf `"  img.src=dataUri;"' _n
            file write _wcf `"}"' _n

    }
    }

    file write _wcf `"</script>"' _n
    file write _wcf `"</body></html>"' _n

    file close _wcf

    di as result `"Word cloud saved → `savefile'"'
    di as text   "Open in any web browser to view."

    restore
end


// =============================================================================
// MATA: wc_concat_rows(varname)
//   Concatenates all string values in varname into observation 1,
//   space-separated. Avoids macro length limits on large datasets.
// =============================================================================
mata:
void wc_concat_rows(string scalar varname)
{
    // Concatenate all rows into one string in Mata (no Stata truncation risk).
    // We restrype the column to strL before writing back so st_sstore does
    // not silently truncate the buffer to the original fixed storage width
    // (e.g. str200 would cut off anything beyond 200 chars).
    real   scalar n, i, col
    string scalar buf

    col = st_varindex(varname)
    n   = st_nobs()
    buf = ""
    for (i = 1; i <= n; i++) {
        buf = buf + " " + st_sdata(i, col)
    }
    // Restrype to strL so the full concatenated string is stored without truncation
    stata("recast strL " + varname)
    col = st_varindex(varname)   // refresh index after recast
    st_sstore(1, col, buf)
}
end


// =============================================================================
// MATA: wc_tokenize(varname)
//   Reads the concatenated string from observation 1 of varname,
//   splits on whitespace using tokens(), then rebuilds the Stata dataset
//   with one word per row. Avoids Stata's split/reshape variable-naming issues.
// =============================================================================
mata:
void wc_tokenize(string scalar varname)
{
    // tokens() splits on whitespace — handles strL fine via st_sdata.
    // We hold all tokens in a Mata string vector (no length limit),
    // restrype the Stata column to strL, then store one token per row.
    string vector toks
    real   scalar n, i, col
    string scalar full

    col  = st_varindex(varname)
    full = st_sdata(1, col)          // read full concatenated string
    toks = tokens(full)              // split on whitespace in Mata
    n    = length(toks)

    if (n == 0) return

    st_addobs(n - 1)                 // dataset has 1 row; add n-1 more
    // Ensure column is strL so individual tokens store without truncation
    stata("recast strL " + varname)
    col = st_varindex(varname)       // refresh after recast
    for (i = 1; i <= n; i++) {
        st_sstore(i, col, toks[i])
    }
}
end


// =============================================================================
// MATA: wc_place_words(W, H, margin, nwords)
//
//   Implements the layout algorithm from amueller/word_cloud:
//
//   For each word i (sorted largest-first in the Stata dataset):
//     1. Read bounding box (bw_i x bh_i) from Stata vars bw, bh
//     2. Search for a collision-free top-left (px, py) using an
//        Archimedean spiral from canvas centre:
//            x(t) = cx + t*cos(t) - bw_i/2
//            y(t) = cy + t*sin(t) - bh_i/2
//        t increments by dt = 0.1 rad.
//     3. At each candidate, AABB test (Axis-Aligned Bounding Box) against every already-placed box:
//            overlap iff NOT (right_i<=left_j OR right_j<=left_i
//                             OR bot_i<=top_j OR bot_j<=top_i)
//     4. No collision + within bounds → place; record box.
//     5. Spiral exhausted → word skipped (placed stays 0).
// =============================================================================
mata:
void wc_place_words(real scalar W,
                    real scalar H,
                    real scalar margin,
                    real scalar nwords)
{
    real scalar cx, cy, dt, max_t
    real scalar t, r, bw_i, bh_i, cx_i, cy_i
    real scalar j, overlap, found, nplaced
    real matrix boxes
    real scalar col_bw, col_bh, col_px, col_py, col_placed
    real scalar i

    col_bw     = st_varindex("bw")
    col_bh     = st_varindex("bh")
    col_px     = st_varindex("px")
    col_py     = st_varindex("py")
    col_placed = st_varindex("placed")

    cx = W / 2
    cy = H / 2

    dt    = 0.01
    max_t = 2 * pi() * sqrt(W^2 + H^2)

    boxes   = J(nwords, 4, 0)
    nplaced = 0

    for (i = 1; i <= nwords; i++) {

        bw_i  = st_data(i, col_bw)
        bh_i  = st_data(i, col_bh)
        found = 0

        for (t = 0; t <= max_t; t = t + dt) {
            r    = t
            cx_i = cx + r * cos(t) - bw_i / 2
            cy_i = cy + r * sin(t) - bh_i / 2

            // Must fit fully inside canvas
            if (cx_i < 0 | cx_i + bw_i > W |
                cy_i < 0 | cy_i + bh_i > H) continue

            // AABB test against all placed boxes
            overlap = 0
            for (j = 1; j <= nplaced; j++) {
                if (!( cx_i + bw_i          <= boxes[j,1]             |
                       boxes[j,1] + boxes[j,3] <= cx_i                |
                       cy_i + bh_i          <= boxes[j,2]             |
                       boxes[j,2] + boxes[j,4] <= cy_i               )) {
                    overlap = 1
                    break
                }
            }

            if (!overlap) {
                found             = 1
                nplaced           = nplaced + 1
                boxes[nplaced, 1] = cx_i
                boxes[nplaced, 2] = cy_i
                boxes[nplaced, 3] = bw_i
                boxes[nplaced, 4] = bh_i
                st_store(i, col_px,     cx_i)
                st_store(i, col_py,     cy_i)
                st_store(i, col_placed, 1)
                break
            }
        }
        // !found → word silently skipped
    }
}
end

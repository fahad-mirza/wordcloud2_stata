{smcl}
{* *! wordcloud2 v1.2.0 (Beta)  Fahad Mirza & Claude  21feb2026}{...}
{viewerjumpto "Syntax" "wordcloud2##syntax"}{...}
{viewerjumpto "Description" "wordcloud2##description"}{...}
{viewerjumpto "Options" "wordcloud2##options"}{...}
{viewerjumpto "Color formats" "wordcloud2##colors"}{...}
{viewerjumpto "Palette integration" "wordcloud2##palette"}{...}
{viewerjumpto "Export" "wordcloud2##export"}{...}
{viewerjumpto "Examples" "wordcloud2##examples"}{...}
{viewerjumpto "Processing pipeline" "wordcloud2##pipeline"}{...}
{viewerjumpto "Authors" "wordcloud2##authors"}{...}

{title:Title}

{phang}
{bf:wordcloud2} {hline 2} Interactive word cloud generator with collision-free layout {it:(Beta)}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:wordcloud2}{cmd:,}
{cmdab:textvar(}{it:varname}{cmd:)}
[{it:options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{cmdab:textvar(}{it:varname}{cmd:)}}string variable containing free text{p_end}

{syntab:Text processing}
{synopt:{cmdab:maxw:ords(}{it:#}{cmd:)}}maximum number of words to display; default is {cmd:maxwords(100)}{p_end}
{synopt:{cmdab:minf:req(}{it:#}{cmd:)}}minimum word frequency to include; default is {cmd:minfreq(2)}{p_end}
{synopt:{cmdab:minl:ength(}{it:#}{cmd:)}}minimum word character length; default is {cmd:minlength(3)}{p_end}
{synopt:{cmdab:stopw:ords(}{it:string}{cmd:)}}space-delimited list of additional stopwords to remove{p_end}
{synopt:{cmd:nostopwords}}suppress built-in English stopword removal{p_end}
{synopt:{cmd:noclean}}suppress lowercasing and punctuation removal{p_end}

{syntab:Appearance}
{synopt:{cmdab:ti:tle(}{it:string}[{cmd:,} {cmd:color(}{it:color}{cmd:)} {cmd:size(}{it:size}{cmd:)}]{cmd:)}}chart title with optional color and font size{p_end}
{synopt:{cmdab:w:idth(}{it:#}{cmd:)}}canvas width in pixels; default is {cmd:width(900)}{p_end}
{synopt:{cmdab:h:eight(}{it:#}{cmd:)}}canvas height in pixels; default is {cmd:height(500)}{p_end}
{synopt:{cmdab:mar:gin(}{it:#}{cmd:)}}minimum padding between words in pixels; default is {cmd:margin(6)}{p_end}
{synopt:{cmdab:maxf:ontsize(}{it:#}{cmd:)}}font size of the most frequent word; default is {cmd:maxfontsize(80)}{p_end}
{synopt:{cmdab:minf:ontsize(}{it:#}{cmd:)}}font size of the least frequent word; default is {cmd:minfontsize(10)}{p_end}
{synopt:{cmdab:bgc:olor(}{it:color}{cmd:)}}background color; default is {cmd:bgcolor(#16213e)}{p_end}
{synopt:{cmdab:pal:ette(}{it:name}{cmd:)}}color palette name from Ben Jann's {cmd:colorpalette}{p_end}

{syntab:Output}
{synopt:{cmdab:savef:ile(}{it:filename}{cmd:)}}output HTML file path; default is {cmd:savefile(wordcloud2.html)}{p_end}
{synopt:{cmdab:exp:ort(}{it:format}{cmd:)}}add a save button to the HTML for static export ({cmd:png}, {cmd:jpg}, or {cmd:svg}){p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:wordcloud2} reads a string variable containing free text, counts word
frequencies across all observations, and renders the results as an interactive
HTML/SVG word cloud. Words are sized proportionally to their frequency and
placed using a collision-free Archimedean spiral layout algorithm. The output
is a self-contained HTML file that can be opened in any modern web browser.

{pstd}
The layout algorithm mirrors the approach used by the Python
{browse "https://github.com/amueller/word_cloud":amueller/word_cloud} library:
bounding boxes are estimated from font metrics, candidate positions spiral
outward from the canvas centre, and axis-aligned bounding box (AABB) collision
tests ensure words never overlap. Words that cannot be placed within the canvas
are silently omitted.

{pstd}
The HTML output is interactive: hovering over any word displays a tooltip
showing the word and its exact frequency count. If {cmd:export()} is specified,
a download button is embedded in the page for static export.

{pstd}
{cmd:wordcloud2} uses {cmd:preserve} and {cmd:restore} internally, so the
caller's dataset is never modified.


{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{cmdab:textvar(}{it:varname}{cmd:)} specifies the string variable containing
the free text to visualise. All observations are concatenated before
processing. The variable may be any string type, including {cmd:strL}.

{dlgtab:Text processing}

{phang}
{cmdab:maxw:ords(}{it:#}{cmd:)} sets the maximum number of words shown in the
cloud. Words are selected by frequency (most frequent first) before the layout
algorithm runs. Default is {cmd:100}.

{phang}
{cmdab:minf:req(}{it:#}{cmd:)} excludes words appearing fewer than {it:#}
times. Raising this threshold reduces noise in large corpora. Default is
{cmd:2}.

{phang}
{cmdab:minl:ength(}{it:#}{cmd:)} excludes words shorter than {it:#}
characters after cleaning. Default is {cmd:3}.

{phang}
{cmdab:stopw:ords(}{it:string}{cmd:)} specifies additional stopwords as a
space-delimited list. These supplement the built-in English stopword list
unless {cmd:nostopwords} is also specified.

{pmore}
Example: {cmd:stopwords(respondent survey questionnaire n/a)}

{phang}
{cmd:nostopwords} suppresses the built-in English stopword list. Only words
supplied in {cmd:stopwords()}, if any, are removed. Use this when analysing
text in languages other than English or when the default list is too aggressive.

{phang}
{cmd:noclean} suppresses automatic text normalisation. By default,
{cmd:wordcloud2} lowercases all text and replaces any character that is not a
letter (a-z) or space with a space. Specifying {cmd:noclean} passes the text
through unchanged.

{dlgtab:Appearance}

{phang}
{cmdab:ti:tle(}{it:string}[{cmd:,} {cmd:color(}{it:color}{cmd:)}
{cmd:size(}{it:size}{cmd:)}]{cmd:)} sets the chart title displayed above the
word cloud. The title text is separated from sub-options by a comma.
Sub-options may appear in any order.

{pmore}
{cmd:color(}{it:color}{cmd:)} sets the title text color using any CSS color
value. Default is {cmd:color(#eeeeee)}. See
{help wordcloud2##colors:Color formats}.

{pmore}
{cmd:size(}{it:size}{cmd:)} sets the title font size. Accepts any CSS
font-size value. A plain number with no unit is treated as {it:em}.
Default is {cmd:size(1.4em)}.

{pmore}
Examples:

{pmore2}
{cmd:title("Customer Feedback")}{break}
{cmd:title("Customer Feedback", color(#ff6b6b))}{break}
{cmd:title("Customer Feedback", size(2em))}{break}
{cmd:title("Customer Feedback", color(white) size(28px))}{break}
{cmd:title("Customer Feedback", color(rgb(0,128,255)) size(2em))}

{phang}
{cmdab:w:idth(}{it:#}{cmd:)} sets the SVG canvas width in pixels.
Default is {cmd:900}.

{phang}
{cmdab:h:eight(}{it:#}{cmd:)} sets the SVG canvas height in pixels.
Default is {cmd:500}.

{phang}
{cmdab:mar:gin(}{it:#}{cmd:)} sets the minimum whitespace gap between words in
pixels. Larger values produce sparser clouds. Default is {cmd:6}.

{phang}
{cmdab:maxf:ontsize(}{it:#}{cmd:)} sets the font size in pixels assigned to
the most frequent word. Font sizes are linearly interpolated on the square root
of frequency between {cmd:minfontsize} and {cmd:maxfontsize}. Default is
{cmd:80}.

{phang}
{cmdab:minf:ontsize(}{it:#}{cmd:)} sets the font size in pixels assigned to
the least frequent word. Default is {cmd:10}.

{phang}
{cmdab:bgc:olor(}{it:color}{cmd:)} sets the background color of both the page
and the SVG canvas. Default is {cmd:bgcolor(#16213e)} (dark navy). Accepts the
same CSS color formats as the {cmd:color()} sub-option of {cmd:title()};
see {help wordcloud2##colors:Color formats}.

{phang}
{cmdab:pal:ette(}{it:name}{cmd:)} specifies a color palette for the word
cloud using Ben Jann's {cmd:colorpalette} package. Any palette recognised by
{cmd:colorpalette} may be used. If {cmd:colorpalette} is not installed or the
palette name is unrecognised, {cmd:wordcloud2} falls back to its built-in
ten-color Tableau-inspired palette with a warning. See
{help wordcloud2##palette:Palette integration}.

{dlgtab:Output}

{phang}
{cmdab:savef:ile(}{it:filename}{cmd:)} specifies the output HTML file path.
Any existing file is replaced. Default is {cmd:wordcloud2.html} in the current
working directory.

{phang}
{cmdab:exp:ort(}{it:format}{cmd:)} embeds a download button in the HTML page.
Accepted values are {cmd:png}, {cmd:jpg} (or {cmd:jpeg}), and {cmd:svg}. The
exported file is saved to the same directory and filename stem as
{cmd:savefile()}.

{pmore}
Example: {cmd:savefile(results/cloud.html) export(png)} embeds a button that
downloads {cmd:results/cloud.png}.

{pmore}
See {help wordcloud2##export:Export} for details.


{marker colors}{...}
{title:Color formats}

{pstd}
Both {cmd:bgcolor()} and the {cmd:color()} sub-option of {cmd:title()} accept
any valid CSS color value in a consistent bare format — no extra quotation marks
are needed.

{p2colset 5 30 31 2}{...}
{p2col:{it:Format}}Example{p_end}
{p2line}
{p2col:Hex shorthand}{cmd:bgcolor(#fff)}{p_end}
{p2col:Hex full}{cmd:bgcolor(#16213e)}{p_end}
{p2col:Named color}{cmd:bgcolor(white)}{cmd:, bgcolor(navy)}{p_end}
{p2col:RGB}{cmd:bgcolor(rgb(0,30,60))}{p_end}
{p2col:RGBA (with alpha)}{cmd:bgcolor(rgba(0,30,60,0.9))}{p_end}
{p2col:HSL}{cmd:bgcolor(hsl(220,60%,15%))}{p_end}
{p2line}
{p2colreset}{...}

{pstd}
Named CSS colors include common names such as {cmd:white}, {cmd:black},
{cmd:navy}, {cmd:steelblue}, {cmd:tomato}, {cmd:gold}, {cmd:lightgray}, and
hundreds of others. A full reference is available at
{browse "https://developer.mozilla.org/en-US/docs/Web/CSS/named-color":MDN Web Docs}.


{marker palette}{...}
{title:Palette integration}

{pstd}
{cmd:wordcloud2} integrates with Ben Jann's
{browse "https://repec.sowi.unibe.ch/stata/palettes/":colorpalette} package.
Install from SSC if needed:

{phang2}{cmd:. ssc install palettes, replace}{p_end}
{phang2}{cmd:. ssc install colrspace, replace}{p_end}
{phang2}{cmd:. ssc install moremata, replace}{p_end}

{pstd}
When {cmd:palette(}{it:name}{cmd:)} is specified, {cmd:wordcloud2} internally
calls {cmd:colorpalette} {it:name}{cmd:, n(}{it:nplaced}{cmd:) nograph}, where
{it:nplaced} is the number of words successfully placed in the layout. The
palette is automatically interpolated or cycled to exactly that number of
colors. Colors returned by {cmd:colorpalette} as Stata RGB triplets
({it:"R G B"}) are converted to CSS {cmd:rgb(R,G,B)} notation for the HTML.

{pstd}
Some commonly used palette names:

{p2colset 5 20 21 2}{...}
{p2col:{it:Name}}Description{p_end}
{p2line}
{p2col:{cmd:Set1}}ColorBrewer qualitative, high contrast{p_end}
{p2col:{cmd:Set2}}ColorBrewer qualitative, pastel tones{p_end}
{p2col:{cmd:Set3}}ColorBrewer qualitative, 12 colors{p_end}
{p2col:{cmd:Dark2}}ColorBrewer qualitative, darker tones{p_end}
{p2col:{cmd:Accent}}ColorBrewer qualitative with accents{p_end}
{p2col:{cmd:Paired}}ColorBrewer qualitative, paired colors{p_end}
{p2col:{cmd:tableau}}Tableau 10 (Tableau's default palette){p_end}
{p2col:{cmd:viridis}}Perceptually uniform, blue-green-yellow{p_end}
{p2col:{cmd:plasma}}Perceptually uniform, purple-orange{p_end}
{p2col:{cmd:magma}}Perceptually uniform, black-purple-yellow{p_end}
{p2col:{cmd:inferno}}Perceptually uniform, black-red-yellow{p_end}
{p2line}
{p2colreset}{...}

{pstd}
If {cmd:palette()} is not specified, {cmd:wordcloud2} uses a built-in
ten-color Tableau-inspired palette that cycles for word counts above ten.


{marker export}{...}
{title:Export}

{pstd}
Specifying {cmd:export()} adds a "Save as" button to the rendered HTML page.
The exported file is saved to the same path as {cmd:savefile()} with the chosen
extension replacing {cmd:.html}. Export requires opening the HTML file in a
browser; it cannot be triggered from within Stata.

{pstd}
{ul:PNG and JPG} — The SVG is drawn onto an off-screen HTML5 Canvas. The
background is filled first with the {cmd:bgcolor()} color (important for JPG,
which cannot represent transparency), and the canvas is then exported via the
browser's {cmd:toDataURL()} API. This is entirely client-side and requires no
additional software.

{pstd}
{ul:SVG} — The SVG element is serialised directly using the browser's
{cmd:XMLSerializer} and downloaded as a vector file. SVG output scales without
quality loss and can be edited in vector graphics applications.


{marker examples}{...}
{title:Examples}

{pstd}
All examples below use the following synthetic dataset of open-ended survey
responses. Enter or load it before running any of the examples.

{phang2}{cmd:clear}{p_end}
{phang2}{cmd:input str200 response}{p_end}
{phang2}{cmd:"The product quality is excellent and the service was outstanding"}{p_end}
{phang2}{cmd:"Great quality but delivery was slow and customer service needs improvement"}{p_end}
{phang2}{cmd:"Amazing experience with the product and very helpful support team"}{p_end}
{phang2}{cmd:"Poor quality product arrived damaged and customer service was unhelpful"}{p_end}
{phang2}{cmd:"Outstanding quality and excellent delivery speed highly recommend"}{p_end}
{phang2}{cmd:"The service team was helpful but the product quality could be better"}{p_end}
{phang2}{cmd:"Excellent customer experience product quality exceeded my expectations"}{p_end}
{phang2}{cmd:"Good quality product but packaging was damaged during delivery"}{p_end}
{phang2}{cmd:"Highly recommend excellent quality and very fast delivery service"}{p_end}
{phang2}{cmd:"The support team was amazing and the product quality is outstanding"}{p_end}
{phang2}{cmd:"Product quality is good but customer service response was very slow"}{p_end}
{phang2}{cmd:"Great delivery service but product quality did not meet expectations"}{p_end}
{phang2}{cmd:"Excellent quality product and outstanding customer service experience"}{p_end}
{phang2}{cmd:"The product arrived damaged but the customer service team was helpful"}{p_end}
{phang2}{cmd:"Amazing support team excellent delivery and outstanding product quality"}{p_end}
{phang2}{cmd:end}{p_end}

{pstd}{ul:Example 1 — Basic call using all defaults}{p_end}

{pstd}
The simplest usage: just point {cmd:wordcloud2} at the text variable.
The built-in English stopword list is applied, words appearing fewer than
twice are dropped, and the result is saved as {cmd:wordcloud2.html} in the
current working directory.

{phang2}{cmd:. wordcloud2, textvar(response)}{p_end}

{pstd}{ul:Example 2 — Full customisation with export}{p_end}

{pstd}
A fully customised call matching the options available in {cmd:wordcloud2}.
This example uses all words (including rare ones), suppresses the built-in
stopword list, applies the Tableau color palette on a white background,
adjusts canvas dimensions and font scaling, and embeds a PNG download button.

{phang2}
{cmd:. wordcloud2,}{break}
{cmd:      textvar(response)}{break}
{cmd:      maxwords(80)}{break}
{cmd:      minfreq(1)}{break}
{cmd:      minlength(4)}{break}
{cmd:      title("Customer Feedback Word Cloud", color(rgb(100,100,100)) size(4))}{break}
{cmd:      palette(tableau)}{break}
{cmd:      width(1000)}{break}
{cmd:      height(550)}{break}
{cmd:      margin(1)}{break}
{cmd:      maxfontsize(100)}{break}
{cmd:      minfontsize(10)}{break}
{cmd:      nostopwords}{break}
{cmd:      bgcolor(rgb(255,255,255))}{break}
{cmd:      savefile("feedback_cloud.html")}{break}
{cmd:      export(png)}
{p_end}

{pstd}
To open the saved HTML file in your default browser after running the command:

{phang2}{cmd:. shell start feedback_cloud.html}{space 5}{it:(Windows)}{p_end}
{phang2}{cmd:. shell open feedback_cloud.html}{space 6}{it:(Mac)}{p_end}
{phang2}{cmd:. shell xdg-open feedback_cloud.html}{space 3}{it:(Linux)}{p_end}

{pstd}{ul:Example 3 — Variations on title and color}{p_end}

{pstd}
Exploring different title and background color options on the same data.

{phang2}{cmd:. wordcloud2, textvar(response) title("Customer Feedback")}{p_end}

{phang2}{cmd:. wordcloud2, textvar(response) title("Customer Feedback", color(#ff6b6b) size(2em))}{p_end}

{phang2}{cmd:. wordcloud2, textvar(response) title("Customer Feedback", color(rgb(0,128,255)) size(2em)) bgcolor(#1a1a2e)}{p_end}

{phang2}{cmd:. wordcloud2, textvar(response) title("Customer Feedback", color(white) size(28px)) bgcolor(#2c3e50)}{p_end}

{pstd}{ul:Example 4 — Color palettes}{p_end}

{pstd}
Requires {cmd:colorpalette} and {cmd:colrspace} from SSC. If not installed,
{cmd:wordcloud2} falls back to the built-in tab10 palette with a warning.

{phang2}{cmd:. wordcloud2, textvar(response) palette(Set1)}{p_end}

{phang2}{cmd:. wordcloud2, textvar(response) palette(Dark2) bgcolor(white)}{p_end}

{phang2}{cmd:. wordcloud2, textvar(response) palette(viridis) bgcolor(#16213e)}{p_end}

{pstd}{ul:Example 5 — Filtering and stopwords}{p_end}

{pstd}
Tighten the word selection by raising frequency and length thresholds, or
provide domain-specific stopwords to remove alongside the built-in list.

{phang2}{cmd:. wordcloud2, textvar(response) minfreq(3) minlength(5)}{p_end}

{phang2}{cmd:. wordcloud2, textvar(response) minfreq(1) nostopwords}{p_end}

{phang2}{cmd:. wordcloud2, textvar(response) stopwords(product service) minfreq(2)}{p_end}

{pstd}{ul:Example 6 — Static export formats}{p_end}

{phang2}{cmd:. wordcloud2, textvar(response) savefile(feedback_cloud.html) export(png)}{p_end}

{phang2}{cmd:. wordcloud2, textvar(response) savefile(feedback_cloud.html) export(jpg)}{p_end}

{phang2}{cmd:. wordcloud2, textvar(response) savefile(feedback_cloud.html) export(svg)}{p_end}

{pstd}{ul:Example 7 — Using your own data}{p_end}

{pstd}
Replace the synthetic data above with a real survey dataset. The variable
passed to {cmd:textvar()} must be a string variable; all observations are
pooled before processing.

{phang2}
{cmd:. use "your_survey_data.dta", clear}{break}
{p_end}

{phang2}
{cmd:. wordcloud2,}{break}
{cmd:      textvar(open_ended_comments)}{break}
{cmd:      maxwords(120)}{break}
{cmd:      minfreq(3)}{break}
{cmd:      title("Open-Ended Survey Responses")}{break}
{cmd:      savefile("survey_wordcloud.html")}
{p_end}


{marker pipeline}{...}
{title:Processing pipeline}

{pstd}
{cmd:wordcloud2} processes text through ten sequential steps. The caller's
dataset is preserved and restored on exit regardless of whether the command
succeeds or fails.

{phang}
{bf:Step 1 — Concatenation.}
All observations of {it:varname} are joined into a single master string using a
Mata routine ({cmd:wc_concat_rows}) that writes to a {cmd:strL} variable,
avoiding Stata macro length limits.

{phang}
{bf:Step 2 — Cleaning.}
Unless {cmd:noclean} is specified, the text is lowercased, any character
outside a-z or space is replaced with a space, and runs of whitespace are
collapsed.

{phang}
{bf:Step 3 — Tokenisation.}
The master string is split on whitespace by Mata's {cmd:tokens()} function,
producing one word per observation.

{phang}
{bf:Step 4 — Stopword and length filtering.}
Unless {cmd:nostopwords} is specified, the built-in English stopword list
(based on the amueller/word_cloud defaults) is applied, supplemented by any
words in {cmd:stopwords()}. Words shorter than {cmd:minlength} are also
dropped.

{phang}
{bf:Step 5 — Frequency counting.}
Unique words are counted with {cmd:contract}. Words below {cmd:minfreq} are
dropped, the result is sorted descending, and it is capped at {cmd:maxwords}.

{phang}
{bf:Step 6 — Font sizing.}
Font sizes are computed by linearly mapping the square root of each word's
frequency onto [{cmd:minfontsize}, {cmd:maxfontsize}]. The square-root
transformation compresses the range so that rarer words remain legible.

{phang}
{bf:Step 7 — Bounding boxes.}
Each word's pixel bounding box is estimated from its font size and character
count (width ≈ 0.6 × font size × characters; height ≈ 1.2 × font size),
padded by {cmd:margin} on each side.

{phang}
{bf:Step 8 — Layout.}
A Mata routine ({cmd:wc_place_words}) places words largest-first. For each
word, positions are tested along an Archimedean spiral from the canvas centre.
Each candidate is checked against all previously placed words using AABB
collision detection. Words that exhaust the spiral without finding a valid
position are silently dropped from the output.

{phang}
{bf:Step 9 — Color assignment.}
If {cmd:palette()} is specified and {cmd:colorpalette} is installed,
{cmd:colorpalette} is called to generate exactly as many colors as were placed.
Otherwise the built-in ten-color palette is used, cycling for larger word
counts.

{phang}
{bf:Step 10 — HTML output.}
A self-contained HTML file is written containing the SVG cloud, hover tooltip
JavaScript, and (if {cmd:export()} is specified) the in-browser export
function.


{marker authors}{...}
{title:Authors}

{pstd}
{bf:Fahad Mirza} (Author)

{pmore}
{browse "https://www.linkedin.com/in/fahad-mirza/":LinkedIn}{space 3}
{browse "https://medium.com/@fahad-mirza": Medium Blog}{space 3}
{browse "https://github.com/fahad-mirza/":GitHub}

{pstd}
{bf:Claude} (Anthropic) | Editor and Co-developer. This program was built
collaboratively between the author and Claude, which assisted with algorithm
implementation, debugging, and feature development.

{title:Note}

{pstd}
{cmd:wordcloud2} is currently in {bf:Beta}. The core functionality is stable
but improvements, new options, and refinements are planned over time. Feedback
and bug reports are welcome via the project GitHub page.

{pstd}
{cmd:wordcloud2} requires Stata 15 or later ({cmd:ustrregexra} and {cmd:strL}
support). The {cmd:palette()} option additionally requires {cmd:colorpalette}
and {cmd:colrspace} by Ben Jann (available from SSC).


{title:Also see}

{psee}
{bf:Project repository:} {browse "https://github.com/fahad-mirza/wordcloud2_stata":wordcloud2 on GitHub}
{p_end}


{psee}
{bf:Dependency:} {browse "https://repec.sowi.unibe.ch/stata/palettes/":colorpalette documentation (Ben Jann)}
{p_end}

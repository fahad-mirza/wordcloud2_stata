********************************************************************************
* wordcloud2_example.do
* Example usage of wordcloud2.ado
* Demonstrates the ADO with a synthetic dataset of open-ended survey responses
********************************************************************************

* ── SETUP ────────────────────────────────────────────────────────────────────
* Place wordcloud2.ado and wordcloud2.sthlp in your personal ado path.
* Find yours with: adopath
* Typically: ~/ado/personal/    (Mac/Linux)
*             C:\ado\personal\  (Windows)

* Or just place the files in the same directory as your do-file and run:
* adopath + "C:\path\to\your\folder"


* ── EXAMPLE 1: Synthetic survey data ─────────────────────────────────────────
clear
input str200 response
"The product quality is excellent and the service was outstanding"
"Great quality but delivery was slow and customer service needs improvement"
"Amazing experience with the product and very helpful support team"
"Poor quality product arrived damaged and customer service was unhelpful"
"Outstanding quality and excellent delivery speed highly recommend"
"The service team was helpful but the product quality could be better"
"Excellent customer experience product quality exceeded my expectations"
"Good quality product but packaging was damaged during delivery"
"Highly recommend excellent quality and very fast delivery service"
"The support team was amazing and the product quality is outstanding"
"Product quality is good but customer service response was very slow"
"Great delivery service but product quality did not meet expectations"
"Excellent quality product and outstanding customer service experience"
"The product arrived damaged but the customer service team was helpful"
"Amazing support team excellent delivery and outstanding product quality"
end

* Basic call — all defaults
wordcloud2, textvar(response)

* ── EXAMPLE 2: Custom options ────────────────────────────────────────────────
wordcloud2,                                  ///
    textvar(response)                        ///
    maxwords(80)                             ///
    minfreq(1)                               ///
    minlength(4)                             ///
    title("Customer Feedback Word Cloud", 	 /// 
			color(rgb(100,100,100)) size(4)) ///
	palette(tableau) 						 ///
    width(1000)                              ///
    height(550)                              ///
    margin(1)                                ///
    maxfontsize(100)                          ///
    minfontsize(10)                          ///
    nostopwords             				 ///
    savefile("feedback_cloud.html") 		 ///
	bgcolor(rgb(255,255,255)) 			 	 ///
	export(png)

* Open the output in your default browser (Windows)
* shell start feedback_cloud.html

* Open the output in your default browser (Mac)
* shell open feedback_cloud.html

* Open the output in your default browser (Linux)
* shell xdg-open feedback_cloud.html


* ── EXAMPLE 3: Real dataset (if you have one) ────────────────────────────────
/*
use "your_survey_data.dta", clear

wordcloud2,                          ///
    textvar(open_ended_comments)     ///
    maxwords(120)                    ///
    minfreq(3)                       ///
    title("Open-Ended Survey Responses") ///
    savefile("survey_wordcloud.html")
*/

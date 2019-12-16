/*
 * WordCount in Pig Latin
 * This program removes punctuations and stop words and store top 20 words occurring in the text
 * Author: Joe Qiao
 * Date: 12/15/2019
 * 
 */

-- Load the text and the list of stop words from user raj_ops
inputdata = load '/user/raj_ops/const.txt' as (line:chararray);                                                                                                                                                    
stoplist = load '/user/raj_ops/stopwords.txt' as (stop:chararray);       
                                                                                                                                          
-- lower and tokenize the text
words = FOREACH inputdata GENERATE FLATTEN(TOKENIZE(LOWER(line))) AS word;                                                                                                                                         

-- Use Left Outer Join to match the text with stop words
words = JOIN words BY word LEFT, stoplist BY stop;   

-- Remove all punctuation using filter function                                                                                                                                                              
words = FILTER words BY word MATCHES '\\w+';  

-- Remove any stop words
filtered_words = FILTER words by stoplist::stop IS NULL; 

-- Group the resulting file with respect of words and add up the counts using COUNT function
word_groups = GROUP filtered_words BY word;                                                                                                                                                                        
word_count = FOREACH word_groups GENERATE group AS word , COUNT(filtered_words) AS count;

-- Show only top 20 words using DESC order and LIMIT function                                                                                                                        
ordered_word_count = ORDER word_count BY count DESC;                                                                                                                                                               
word_limit = LIMIT ordered_word_count 20;                                                                                                                                                                          

-- Instead of DUMP the result, I chose to store the result into /user/raj_ops/output/testFinal
STORE word_limit INTO 'output/testFinal';

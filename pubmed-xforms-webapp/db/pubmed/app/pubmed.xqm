xquery version "1.0";

module namespace pubmed = "http://xmlss/pubmed"; 

declare namespace h = "http://www.w3.org/1999/xhtml";



declare function pubmed:to-html($input as item()*) as item()* {
    
    for $node in $input
    return 
    
      typeswitch($node)
        
        case element(PubmedArticle) return
            <h:div id="pubmedArticle">
                {
                    pubmed:to-html($node/PubmedData),
                    pubmed:to-html($node/MedlineCitation)
                }
            </h:div>
        
        
        case element(MedlineCitation) return
            <h:div id="citation">
            {
                pubmed:to-html($node/Article)
            }
            </h:div>
        
        
        case element(Article) return
            (
                <h:div id="article">
                    <h:h2>Article</h:h2>
                    <h:div id="aTitle">
                        <h:label class="key" for="articleTitle">Title:</h:label>&#160;
                        <h:span id="articleTitle" class="val">{$node/ArticleTitle}</h:span>
                    </h:div>
                    <h:div id="authors">
                        <h:h3>Authors</h:h3>
                        {
                            pubmed:to-html($node/AuthorList/Author)
                        }
                    </h:div>
                    <h:div id="abstracts">
                        <h:h3>Abstracts</h:h3>
                        {
                            pubmed:to-html($node/Abstract/AbstractText)
                        }
                    </h:div>
                </h:div>
            ,
                pubmed:to-html($node/Journal)
            )
        
        
        case element(Author) return
            <h:span class="val author">
            {
                string-join(($node/ForeName, $node/LastName), " ")
            }
            </h:span>
        
        
        case element(AbstractText) return
            <h:div class="abstract">
                <h:label class="key">{string($node/@Label)}</h:label>
                <h:p>{$node/text()}</h:p>
            </h:div>
        
        
        case element(Journal) return
            <h:div id="journal">
                <h:h2>Published in Journal</h:h2>
                <h:div class="keyval">
                    <h:label class="key">Title:</h:label>&#160;
                    <h:span class="val">{$node/Title/text()}</h:span>
                </h:div>
                <h:div class="keyval">
                    <h:label class="key">ISSN:</h:label>&#160;
                    <h:span class="val">{$node/ISSN/text()}</h:span>
                </h:div>
                <h:div class="keyval">
                    <h:label class="key">Issue:</h:label>&#160;
                    <h:span class="val">Volume {$node/JournalIssue/Volume/text()}, Issue {$node/JournalIssue/Issue/text()}</h:span>
                </h:div>        
                <h:div class="keyval">
                    <h:label class="key">Date:</h:label>&#160;
                    <h:span class="val">{string-join($node/JournalIssue/PubDate/(Year|Month|Day), "-")}</h:span>
                </h:div>
            </h:div>
        
        
        case element(PubmedData) return
            <h:div id="pubmedData">
                <h:h2>Pubmed Data</h:h2>
                <h:label class="key">ID:</h:label>&#160;
                <h:span class="val">
                {
                    let $id := $node/ArticleIdList/ArticleId[@IdType eq "pubmed"]/text() return
                        <h:a href="article/{$id}">{$id}</h:a>
                }
                </h:span>
                <h:div id="history">
                    <h:h3>History</h:h3>
                    {
                        pubmed:to-html($node/History/PubMedPubDate)
                    }
                </h:div>
            </h:div>
        
        
        case element(PubMedPubDate) return
            <h:div class="pubMedPubDate">
                Status <h:span class="val status">{string($node/@PubStatus)}</h:span> on <h:span class="val date">{concat($node/Year, "-", $node/Month, "-", $node/Day)}</h:span>
            </h:div>
        
        
        case element()
           return
              element {name($node)} {
 
                (: output each attribute in this element :)
                for $att in $node/@*
                   return
                      attribute {name($att)} {$att}
                ,
                (: output all the sub-elements of this element recursively :)
                for $child in $node
                   return pubmed:to-html($child/node())
 
              }
        (: otherwise pass it through.  Used for text(), comments, and PIs :)
        default return $node
};

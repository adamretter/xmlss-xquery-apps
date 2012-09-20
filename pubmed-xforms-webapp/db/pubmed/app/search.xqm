xquery version "3.0";

module namespace search = "http://xmlss/search"; 

import module namespace web = "http://xmlss/web" at "web.xqm";

declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare
    %rest:GET
    %rest:path("/pubmed/search")
    %rest:produces("text/html")
    %output:method("xhtml")
function search:page() {
    web:page(
        web:search-page()
    )
};

declare
    %rest:GET
    %rest:path("/pubmed/journal/{$issn}")
    %rest:query-param("start", "{$start}", 1)
    %rest:query-param("count", "{$count}", 10)
function search:by-journal-issn($issn, $start as xs:int, $count as xs:int) {
    <PubmedArticles>
    {
        collection("/db/pubmed/data")/PubmedArticleSet/PubmedArticle
            [MedlineCitation/Article/Journal/ISSN eq $issn]
            [position() ge $start]
            [position() lt $start + $count] 
    }
    </PubmedArticles>
};

declare
    %rest:GET
    %rest:path("/pubmed/journal")
    %rest:query-param("name", "{$name}")
    %rest:query-param("exact", "{$exact}")
    %rest:query-param("start", "{$start}", 1)
    %rest:query-param("count", "{$count}", 10)
function search:by-journal-name($name, $exact, $start as xs:integer, $count as xs:integer) {
    <PubmedArticles>
    {
        if($exact and $exact eq "false")then
            (: fulltext match :)
            search:by-journal-name-ft($name, $start, $count)
        
        else
            (: exact match :)
            search:by-journal-name-exact($name, $start, $count)
    }
    </PubmedArticles>
};

declare
    %rest:GET
    %rest:path("/pubmed/article")
    %rest:query-param("author", "{$author}")
    %rest:query-param("after-year", "{$after-year}")
    %rest:query-param("start", "{$start}", 1)
    %rest:query-param("count", "{$count}", 10)
function search:by-article($author, $after-year as xs:integer, $start as xs:integer, $count as xs:integer) {
    <PubmedArticles>
    {    
        if($author)then
            search:by-author($author, $start, $count)
        
        else if($after-year) then
            search:by-date($after-year, $start, $count)
        else
            (: all articles! :)
            search:list-articles($start, $count)
    }
    </PubmedArticles>
};

declare
    %rest:GET
    %rest:path("/pubmed/article/{$pubmedid}")
    %rest:produces("text/html")
    %output:method("html")
function search:article-html($pubmedid as xs:integer) {
    let $article := collection("/db/pubmed/data")/PubmedArticleSet/PubmedArticle[descendant::ArticleId eq $pubmedid]
    return
    
        web:page(web:view-article-page($article))
};

(:
declare
    %rest:GET
    %rest:path("/pubmed/article/{$pubmedid}")
    %rest:produces("application/xml")
function search:article($pubmedid as xs:integer) {
    collection("/db/pubmed/data")/PubmedArticleSet/PubmedArticle
        [descendant::ArticleId eq $pubmedid]
};
:)

declare function search:by-journal-name-exact($name, $start, $count) {
    collection("/db/pubmed/data")/PubmedArticleSet/PubmedArticle
        [MedlineCitation/Article/Journal/Title eq $name]
        [position() ge $start]
        [position() lt $start + $count]
};

declare function search:by-journal-name-ft($name, $start, $count) {
    collection("/db/pubmed/data")/PubmedArticleSet/PubmedArticle
        [ft:query(MedlineCitation/Article/Journal/Title, $name)]
        [position() ge $start]
        [position() lt $start + $count]
};

declare function search:by-author($author, $start, $count) {
  collection("/db/pubmed/data")/PubmedArticleSet/PubmedArticle
    [(descendant::ForeName, descendant::LastName) = $author]
    [position() ge $start]
    [position() lt $start + $count]
};

declare function search:by-date($after-year as xs:integer, $start, $count) {
  collection("/db/pubmed/data")/PubmedArticleSet/PubmedArticle
    [MedlineCitation/DateCreated/Year ge $after-year]
    [position() ge $start]
    [position() lt $start + $count]
};

declare function search:list-articles($start, $count) {
    collection("/db/pubmed/data")/PubmedArticleSet/PubmedArticle
        [position() ge $start]
        [position() lt $start + $count]
};
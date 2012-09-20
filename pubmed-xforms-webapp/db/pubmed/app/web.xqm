xquery version "1.0";

module namespace web = "http://xmlss/web";

import module namespace pubmed = "http://xmlss/pubmed" at "pubmed.xqm";

declare namespace h = "http://www.w3.org/1999/xhtml";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace xf = "http://www.w3.org/2002/xforms";

declare variable $web:res-path := "/exist/rest/db/pubmed/app/resources/";



declare function web:page($content as document-node()) {
    <html xmlns="http://www.w3.org/1999/xhtml">
        { web:page-head($content/h:html/h:head/*) }
        <body>
        {
            web:navbar(),
            $content/h:html/h:body/*
        }
        </body>
    </html>
};

declare function web:page-head($xf-model as element(xf:model)?) {
   <head xmlns="http://www.w3.org/1999/xhtml">
      <title>XML Summer School</title>
      <link rel="stylesheet" type="text/css" href="{$web:res-path}webster.css"/>
      <link rel="stylesheet" type="text/css" href="{$web:res-path}/demostyle.css"/>
      {$xf-model}
   </head>
};

declare function web:navbar() {
    <div id="header" xmlns="http://www.w3.org/1999/xhtml">
        <div id="logo">
            <img src="{$web:res-path}xss_04.jpg"/>
        </div>
        <div id="title">   
            <span style="font-size:18pt;color:#306098;font-family:Arial">Journal Search</span>
        </div>
        <div id="links">
            <span><a href="article">List Articles</a></span>
            <span>|</span>
            <span><a href="search">Search</a></span>
            <span>|</span>
            <span><a href="categories">Categories</a></span>
            <span>|</span>
            <span><a href="sandbox.xql">XQuery</a></span>
        </div>
    </div>
};

declare function web:search-page() {
    doc("/db/pubmed/app/form.xhtml")
};

declare function web:view-article-page($article as element(PubmedArticle)) {
    document {
        <h:html>
            <h:body>{pubmed:to-html($article)}</h:body>
        </h:html>
    }
};
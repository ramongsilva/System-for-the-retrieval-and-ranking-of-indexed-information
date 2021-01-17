<h1>System for the retrieval and ranking of indexed information</h1>
<p>This repository contains files and information about the <strong> step 4 of Kaphta Architecture: System for the retrieval and ranking of indexed information</strong>. In this stage are presented 5 algorithms for 5 search types: search for polyphenol, search for cancer, search for gene, search for polyphenol-cancer, e search for polyphenol-gene. According to the type of search performed, the system retrieves indexed abstracts in past stage (<a href='https://github.com/ramongsilva/Indexing-of-extracted-information'>Indexing of Extracted Information step</a>) and submits them to the ranking algorithm that returns five scores (S1, S2, S3, S4, and S5) for each abstract. In the algorithm, the calculation of S1, S2 and S3 varies according to the type of search. Scores S1 and S2 are calculated considering the number and type of sentence (PC – polyphenol-cancer sentences; PG – polyphenol-gene sentences; P – only polyphenol sentences; C – only cancer sentences; G – only gene sentences) containing recognized entities and rules. The points assigned are different for the different types of sentences (PC, PG, P, C, and G). <br>
  See below Table of points and Algorithm for ranking indexed PubMed abstracts.
  </p>
    <h2>Table of points for S1 and S2 scores calculation on the  retrieval and ranking algorithm</h2>
    <img src='images/Table_with_points.jpg' style="display:block; margin: 0 auto;">
    <h2>Description of algorithm for ranking indexed PubMed abstracts </h2>    
    <p>The algorithm performs the retrieval and ranking of indexed articles based on the user's search type: search for polyphenol, search for cancer, search for gene, search for polyphenol-cancer, or search for polyphenol-gene. From there, the execution continues:</p>
    <p><strong>Search for polyphenol</strong></p>
    <i>
    <ul>
     <li>Input: id of the Polyphenol (P) searched;
     <li>Retrieval of indexed PubMed abstracts related to the P searched, on df_polyphenol_individual_indexation.tsv file;</li>
     <li>Loop start: for each PubMed abstract are calculated the scores:
       <ul>
         <li>S1 = s1_score_calc_PC() +  s1_score_calc_P(); <strong>// where P refers to the polyphenol entity searched, and C can be anything cancer entity</strong></li>
         <li>S2 = s2_score_calc();  <strong>// where P refers to the polyphenol entity searched, and C and G can be anything cancer and gene entities </strong></li>
         <li>S3 = sum of P entities recognized in PubMed abstract;</li>
       </ul>       
     </li>
     <li>Loop end</li>
     <li>Normalization of S1, S2 and S3 scores (0 to 1);</li>
      <li>S4 → (5*S1 + 2*S2 + 3*S3) / 10;
      <li>S5 → result of text classification based on ensemble;</li>
      <li><strong>Result (output) → list of the PubMed abstracts with extracted information and ranking scores calculated</strong>.</li>

    

<?php
//Defining the files
$in = file("migr_asyappctza.tsv");
$out = fopen("migr_asyappctza_unpivot.csv", "w+");

//header in output file
fwrite($out, "citizen,sex,unit,age,asyl_app,geo,time,ammount\n");

$in_array_line1 = explode("\t",$in[0]);
for ($k = 1; $k < count($in); $k++) {
  $in_array_lineK = explode("\t",$in[$k]);
  for($i = 1; $i < count($in_array_line1); $i++){
    $jear = "";   //Correcting the year
    for ($j = 0; $j < 4; $j++) {
      $jear .= $in_array_line1[$i][$j];
    }
    $data_out = $in_array_lineK[0] . "," . $jear . ",";
    if ($in_array_lineK[$i] === ": " or $in_array_lineK[$i] === ": \n") {
      $data_out .= "N/A";
    } else {
      $data_out .= $in_array_lineK[$i];
    }
    $data_out .= "\n";
    fwrite($out, $data_out);
  }
}
fclose($out);
?>

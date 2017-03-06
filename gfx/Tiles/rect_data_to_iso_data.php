<?php
	$start = array(15, 13, 11, 9, 7, 5, 3, 1, 0, 1, 3, 5, 7, 9, 11, 13, 15);
	$length = array(2, 6, 10, 14, 18, 22, 26, 30, 32, 30, 26, 22, 18, 14, 10, 6, 2);
	echo "Converting rectangular data to isometric data...\n";
	for ($a = 1; $a < $argc; $a++ ) {
		$variable = $argv[$a].".asm";
		echo $variable."\n";
		if (file_exists($variable)) {
			$file = fopen($variable, "r+");
			$output = array();
			fgets($file);
			fgets($file);
			fgets($file);
			fgets($file);
			$output[] = substr(fgets($file), 0, -1);
			fgets($file);
			for ($b = 0; $b < 17; $b++) {
				$data = explode(" ", fgets($file));
				$data = explode(",", $data[2]);
				$data = implode(",", array_slice($data, $start[$b], $length[$b]));
				$output[] = " db ".$data;
			}
			fclose($file);
			unlink($variable);
			$file = fopen($variable, "w");
			fwrite($file, implode("\n", $output));
			fclose($file);
		}
	}
?>
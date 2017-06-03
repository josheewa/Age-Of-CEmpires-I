<?php
    if ($argv[1] == "edit") {
        $names = array("gfx2/Buildings/gfx_buildings.inc", "gfx2/Main/gfx_main1.inc", "gfx2/Main/gfx_main2.inc");
        foreach ($names as $name) {
            $file = fopen($name, "r");
            $output = array();
            while (($line = fgets($file)) !== FALSE) {
                $line = str_replace("#include \"", "#include \"" . dirname($name) . "/", $line);
                $output[] = $line;
            }
            fclose($file);
            $file = fopen($name, "w");
            fwrite($file, implode("", $output));
            fclose($file);
        }
    } else {
        $names = array("bin/AOCEGFX1.lab", "bin/AOCEGFX2.lab");
        foreach ($names as $name) {
            $file = fopen($name, "r");
            $output = array();
            while (($line = fgets($file)) !== FALSE) {
                if (strlen($line) > 2 && $line[0] == "_" && $line[1] != "_") {
                    $output[] = $line;
                }
            }
            fclose($file);
            $file = fopen($name, "w");
            fwrite($file, implode("", $output));
            fclose($file);
        }
    }
?>
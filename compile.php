<?php
	ob_start("ob_gzhandler");
	$uploaddir = getcwd() . "/compiler/work/";

	$file_uploaded = 0;
	$arch = 0;

	if (isset($_FILES['file'])) {
		$file_uploaded = 1;
	}
	else if (isset($_POST['filepost'])) {
		$file_uploaded = 2;
	}

	if (!$file_uploaded)
	{
		echo "File is empty or no file uploaded.\n";
?>
		<html><body>
		<form action="compile.php" method="POST">
		<textarea name="filepost" cols=100 rows=40>
.global _start
_start:

		</textarea>
		<input type="submit" value="Compile">
		</form>
		</body></html>

<?php
		exit;
	}

	$tmpfbase = tempnam($uploaddir, "asm");
	$uploadfile = $tmpfbase . ".s";

	if ($file_uploaded == 1) {
		move_uploaded_file($_FILES['file']['tmp_name'], $uploadfile);
	}
	else if ($file_uploaded == 2) {
		file_put_contents( $uploadfile, $_REQUEST['filepost'] . "\n\n\n");
	}

	chdir("$uploaddir/..");
	$cmdline = "./runasm " . "work/" . basename($uploadfile);
	if (isset($_POST['arch'])) {
		$arch = intval($_POST['arch']);
		$cmdline .= " $arch";
	}
	#$asmout[] = "Running $cmdline. file_uploaded=$file_uploaded uploaddir=$uploaddir uploadfile=$uploadfile $tmpfbase";
	exec( $cmdline, $asmout, $rv);

	if (preg_grep('/File too large$/', $asmout)) {
		$asmout[] = "File too large: Reduce code or data size, or compile the program locally. I set a limit of 12 MB because it takes too long to transfer a large file.";
	}
	else if (is_file("${uploadfile}.elf") && filesize($uploadfile . ".elf") > 2097152) {
		$asmout[] = "Your program is &gt;2MB. Consider compiling the program locally instead to avoid the transfer time for a large file.";
	}

	if ($rv != 0) {
		switch ($rv) {
			case 128+4: $asmout[] = "SIGILL: Illegal instruction"; break;
			case 128+6: $asmout[] = "SIGABRT: Aborted"; break;
			case 128+7: $asmout[] = "SIGBUS: Bus error"; break;
			case 128+8: $asmout[] = "SIGFPE: Floating-point exception"; break;
			case 128+9: $asmout[] = "SIGKILL: Killed"; break;
			case 128+11: $asmout[] = "SIGSEGV: Segmentation fault"; break;
			case 128+15: $asmout[] = "SIGTERM: Terminated"; break;
			case 128+24: $asmout[] = "SIGXCPU: CPU time limit exceeded"; break;
			case 128+25: $asmout[] = "SIGXFSZ: File size limit exceeded (Possible causes: Program too big (>12 MB), or improper use of .skip or .org directives)"; break;
		}
		$asmout[] = "Compile failed.";
	}
	else
		$asmout[] = "Compile succeeded.";


	if (file_exists($uploadfile . ".elf") && filesize($uploadfile . ".elf") > 0)
	{
		$fs = filesize($uploadfile . ".elf");
		echo pack("V", $fs);
		readfile("$uploadfile.elf");
	}
	else
	{
		echo pack("V", 0);
	}
	echo implode("\n", $asmout);


	array_map('unlink', glob($tmpfbase . "*"));

	ob_end_flush();
?>

## Load font ====

## Font (Computer Modern) for plots ====
wd <- setwd(tempdir())

ft.url <- "https://www.fontsquirrel.com/fonts/download/computer-modern/computer-modern.zip"
download.file(ft.url, basename(ft.url))
if (!file.exists("cmunrm.ttf")) unzip(basename(ft.url))

font_add("cmr", "cmunrm.ttf")
font_add("cmss", "cmunss.ttf")

showtext_auto()
showtext_opts(dpi = 300)
# Reset working directory to top level
setwd(path)
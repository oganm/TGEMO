library(rmarkdown)
library(ontologyIndex)
library(magrittr)
library(glue)
library(stringr)

# download.file('https://github.com/ontodev/robot/releases/download/v1.9.6/robot.jar',destfile = 'robot.jar')
# system('java -jar robot.jar convert --input TGEMO.OWL --format obo --output TGEMO.obo')

tgemo = ontologyIndex::get_ontology('TGEMO.obo',extract_tags = 'everything')

unlink('site_src/md',recursive = TRUE)
dir.create('site_src/md',recursive=TRUE)

base_files = list.files('site_src/src/')
base_files %>% lapply(\(x){
    file.copy(glue::glue('site_src/src/{x}'),'site_src/md/')
    
})

template = readLines('site_src/src/term_template') %>% paste(collapse = '\n')

for (i in seq_along(tgemo$id)){
    id = tgemo$id[i] %>% gsub(":","_",.,fixed =TRUE)
    id = id %>% str_extract(pattern = 'TGEMO_[0-9]*')
    name = tgemo$name[i]
    description = tgmo$def[[i]] %>%
        gsub("\\]|\\[|\\\"","",x=.) %>%
        trimws()
    
    synonyms = tgemo$synonym[[i]] %>% stringr::str_extract_all('(?<=").*?(?=")') %>%
        unlist
    
    output = glue::glue(template)
    
    writeLines(output,
               glue::glue('site_src/md/{id}.md'))
    
}




rmarkdown::render_site('site_src/md')

unlink('docs',recursive = TRUE)
dir.create('docs')
file.copy(list.files('site_src/md/_site',include.dirs = TRUE,full.names = TRUE),
          'docs',
          recursive = TRUE)


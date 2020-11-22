[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://www.cardiff.ac.uk/wales-governance-centre/publications/finance">
    <img src="https://public.flourish.studio/uploads/0d505dc9-7e81-45d8-b9b4-b9330312cf83.png" width = 150 alt="Logo">
  </a>

  <h3 align="center">GMobility Wales</h3>

  <p align="center">
    A Shiny web app that uses Google data to produce user-friendly, seasonally-adjusted mobility charts for Wales.
    <br />
    <br />
    <a href="https://gmobility.wfa.cymru">View Website</a>
    ·
    <a href="https://github.com/ciantudur/gmobility-wales/issues">Report Bug</a>
    ·
    <a href="https://github.com/ciantudur/gmobility-wales/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
  * [Built With](#built-with)
* [License](#license)
* [Contact](#contact)
* [Acknowledgements](#acknowledgements)



<!-- ABOUT THE PROJECT -->
## About The Project

The web application [app.R](https://github.com/ciantudur/gmobility-wales/blob/main/app.R) allows users to filter a dataset with mobility data for Wales and produce custom charts with the results.

The source data for the web app can be accessed via Dropbox [here](https://www.dropbox.com/s/m269kfh1oii89ad/google_data.csv?dl=1). This is updated twice a week with the latest data from Google.

This dataset is compiled using an R script [prepare_data.R](https://github.com/ciantudur/gmobility-wales/blob/main/prepare_data.R). The script fetches the data from Google and filters for Welsh local authorities. It then imputes missing data for each local authority and for each measure using a Kalman filter (provided that there are no more than 20 consequtive missing values). Google does not provide a data series for Wales, so this is derived using a population-weighted average of the values for the 22 Welsh local authorities. An ARIMA model is then used to remove seasonality. 

### Built With
* [R](https://www.r-project.org/)
* [RShiny](https://shiny.rstudio.com/)


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Cian Tudur - [@ciantudur](https://twitter.com/ciantudur)

Project Link: [https://github.com/ciantudur/gmobility-wales](https://github.com/ciantudur/gmobility)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [Google Mobility Data](https://www.google.com/covid19/mobility/)
* [cowplot package R](https://cran.r-project.org/web/packages/cowplot/index.html)
* [dplyr package R](https://cran.r-project.org/web/packages/dplyr/index.html)
* [ggplot2 package R](https://cran.r-project.org/web/packages/ggplot2/index.html)
* [metathis package R](https://cran.r-project.org/web/packages/metathis/index.html)
* [sf package R](https://cran.r-project.org/web/packages/sf/index.html)
* [here package R](https://cran.r-project.org/web/packages/here/index.html)
* [magrittr package R](https://cran.r-project.org/web/packages/magrittr/index.html)
* [tidyverse package R](https://cran.r-project.org/web/packages/tidyverse/index.html)
* [readr package R](https://cran.r-project.org/web/packages/readr/index.html)
* [RCurl package R](https://cran.r-project.org/web/packages/RCurl/index.html)
* [datasets package R](https://cran.r-project.org/web/packages/datasets/index.html)
* [ggpubr package R](https://cran.r-project.org/web/packages/ggpubr/index.html)
* [imputeTS package R](https://cran.r-project.org/web/packages/imputeTS/index.html)
* [plyr package R](https://cran.r-project.org/web/packages/plyr/index.html)
* [forecast package R](https://cran.r-project.org/web/packages/forecast/index.html)
* [README Template](https://github.com/othneildrew/Best-README-Template/blob/master/README.md)






<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/ciantudur/gmobility-wales.svg?style=flat-square
[contributors-url]: https://github.com/ciantudur/gmobility-wales/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/ciantudur/gmobility-wales.svg?style=flat-square
[forks-url]: https://github.com/ciantudur/gmobility-wales/network/members
[stars-shield]: https://img.shields.io/github/stars/ciantudur/gmobility-wales.svg?style=flat-square
[stars-url]: https://github.com/ciantudur/gmobility-wales/stargazers
[issues-shield]: https://img.shields.io/github/issues/ciantudur/gmobility-wales.svg?style=flat-square
[issues-url]: https://github.com/ciantudur/gmobility-wales/issues
[license-shield]: https://img.shields.io/github/license/ciantudur/gmobility-wales.svg?style=flat-square
[license-url]: https://github.com/ciantudur/gmobility-wales/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=flat-square&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/cian-sion/




# gmobility-wales
Shiny web app that pulls Google Covid-19 mobility data to create user-friendly, seasonally-adjusted charts for Wales and Welsh local authorities.

View the web app in action on https://gmobility.wfa.cymru

app.R contains the code to the web app

The underlying data for the app can be found here: https://www.dropbox.com/s/m269kfh1oii89ad/google_data.csv?dl=1

The c

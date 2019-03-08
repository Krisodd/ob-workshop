# Open Banking .Net Core REST API eksempelprosjekt
Denne kildekoden innholder et eksempel for hvordan implementere et REST API i .Net Core for Open Banking. Innholdet kan brukes som referanse eller som utgangspunkt for et nytt prosjekt.

[![CircleCI](https://circleci.com/gh/SparebankenVest/ob-netcore-api-example.svg?style=svg&circle-token=0ad26e18697080cf4ad6ccd17c802dfee1c93cff)](https://circleci.com/gh/SparebankenVest/ob-netcore-api-example)

## Oppsett

## Contract first
"Contract first" for utvikling av API er en tilnærming der, som navnet tilsier, vi utarbeider kontrakten før vi begynner på implementasjonen. Kontrakten brukes da som en sentral komponent og driver for utvikling, test, dokumentasjon og klientintegrasjon. 

Det vi ønsker å oppnå med denne tilnærmingen er mye større fokus på domenet og bankens egenskap smo vi ønsker å eksponere internt og for andre konsumenter. Kontrakten er maskinlesbar og kan brukes av verktøy for å generere grunnlag for klienter, server kode, automatiserte tester og generere dokumentasjon som grunnlag for utviklerportal.
Kontrakten er også lesbar for mennesker noe som gjør det enklere å utarbeide kontrakten på tvers av 

## Dokumentasjon

## Testing
Prosjektene bør i hovedsak tilrettelegges for tester som kan automatiseres. Testene bør bestå av enhetstester, integrasjonstester, kontraktstester og testing av funksjonelle krav. 

Enkelte tester har til nå vært vanskelig å automatisere, men har likevel en verdi som "utviklingsverkøy" der utvikler kan teste og debugge kode lokalt. Et eksempel på dette er "host-tester"/integrasjonstester som går mot underlevereandørers testmiljø. 

### Enhetstesting
Enhetstestene tester små logiske deler av koden uten "eksterne" avhengigheter og blir gjerne opprettet som en del av utvikling av funksjonalitet(Testdrevet utvikling). Testene bør dekke flere variasjoner av parametere, kunne automatiseres og rapportere resultat i et format som kan leses av CircleCI.

[Coverlet](https://github.com/tonerdo/coverlet) er et godt hjelpemiddel for å måle hvor godt dekket koden er av disse testene. CircleCI har ikke noe innebygget som kan utnytte seg av resultatene fra kodedekning, så dette blir inntil videre kun lagret som en [artifakt](https://circleci.com/docs/2.0/artifacts/). Ved hjelp av [Reportgenerator](https://github.com/danielpalme/ReportGenerator), resultatet ble convertet til en html format rapport som kan hjelpe utviklerne forbedrer testdekning.

Våre prosjekter har i hovedsak utnyttet [NUnit](https://nunit.org/), men [XUnit](https://xunit.github.io/) og [MSTest](https://github.com/Microsoft/testfx-docs) er gode alternativer.

### Integrasjonstester
Til nå har våre integrasjonstester mot underleverandør hovedsaklig vært tester som kjøres manuelt av utviklere og testere. Årsaken til dette har ofte vært at vi ikke har kontroll på innhold og tilstand i underleverandørens testmiljø som ofte disse testene opererer mot. 

Til nå har vi karaktirisert våre "host tester" som utviklingsverktøy som eksekveres manuelt for debugging av vår kode eller for å inspisere resultater fra underleverandørs tjenester.

Vi ønsker å arbeide videre med å automatisere flere av integrasjonstestene for å bli tryggere på at ny funksjonalitet og endringer virker som tiltenkt.

### Kontrakstester
Våre API-kontrakter beskriver hvordan våre konsumenter skal forholde til våre tjenester og inneholder teknisk og tekstlig beskrivelse av APIet. Teknisk implementasjon bør være fraskilt fra kontrakten(les [Contract first](#Contract-first)) og for å etterprøve at implementasjonen faktisk oppfyller det kontrakten beskriver, har vi utnyttet et verktøy som heter [Dredd](https://dredd.org/en/latest/) av Apiary.

I de fleste tilfeller behøver ikke Dredd ekstra konfigurasjon enn kontrakten selv og kan kjøres slik som dette eksempelet([account-api](https://github.com/SparebankenVest/account-api)):
```bash
dredd contracts/account.yaml http://[HOST]/v1/accounts 
```

I mange tilfeller behøver man også å overstyre headere slik som følgende eksempel:
```bash
dredd contracts/account.yaml http://[HOST]/v1/accounts --header="Authorization:Bearer [tokenstring]"
```

For å rapportere testresultat må man bruke et format CircleCI forstår. Selv om det ikke er i listen av støttede formater virker det som om XUnit er nært nok JUnit(som er støttet) til at CircleCI godtar det. Dette kan angis med `--reporter xunit` og lagre resultatet. Fullt eksempel kan sees i eksempelkoden.

Dredd kan også utnyttes for kun validering av kontrakten uten å kjøre selve testene. Dette kan blant annet være nyttig under utarbeiding av kontrakten der vi ennå ikke har implementasjonen på plass. Dette kan gjøres ved å angi flagget `--dry-run`. URL til tjenesten må også angis, men det vil ikke gå noen kall mot den.

For mer avanserte tilfeller kan man definere en egen [konfigurasjonsfil](https://dredd.org/en/latest/quickstart.html#configure-dredd) for Dredd og utnytte [Hooks](https://dredd.org/en/latest/hooks/) som tillater kjøring av kode(JavaScript) før og etter kall under testingen.

For enkelhets skyld innholder foreløpig ikke denne kodebasen eksempler på dette.

En godt definert kontrakt med gode eksempler gjør testing med Dredd bedre.


### API tester av funksjonelle krav
Enhet, integrasjon og kontrakstester er som oftest ikke utformet rundt de funksjonelle kravene APIet skal oppfylle og disse testene bør utformes eksplisitt. Å skrive tester rundt problemstillingene APIet faktisk forsøker å løse og hvordan det skal fremstå "utad" avdekker ofte helt andre ting enn mer "tekniske" tester.
Testene kjøres også "utenfra" og får dermed med alle komponentene som utgjør APIet inkludert gateway, auth og evt. annen mellomvare. 

Til dette formålet har vi til nå testet ut [Postman](https://www.getpostman.com/) som, uavhengig av dette, er et utbredt verktøy internt i SPV og ellers. Inntrykket er at bruken internt har begrenset seg til enkle manuelle kall av eksterne API i forbindelse med utvikling av integrasjoner og ikke til automatisert testing. Dette betyr derimot at verktøyet er godt kjent og ikke krever mye tid til opplæring.

Tester i Postman organiseres i "[Collections](https://learning.getpostman.com/docs/postman/collections/intro_to_collections/)" og mapper og lar oss navngi operasjoner i naturlig språk. Det vil si at du blant annet kan ha flere definerte operasjoner mot samme endepunkt, men med forskjellig formål, innhold og tester.
I tillegg kan man definere flere [miljøer](https://learning.getpostman.com/docs/postman/environments_and_globals/intro_to_environments_and_globals/) med egne innstillinger i form av variabler som kan utnyttes i utforming av kall og i kode.

Postman lar oss utforme kode i JavaScript som kan dynamisk utføre og endre kall og teste responsene. Det er i denne koden du skriver selve testene. Les mer om dette [her](https://learning.getpostman.com/docs/postman/scripts/intro_to_scripts/).

Automatisk kjøring av tester definert i Postman gjøres i kommandolinje med verktøyet [Newman](https://learning.getpostman.com/docs/postman/collection_runs/command_line_integration_with_newman/). Denne kan installeres sammen med en JUnit "reporter" som gjør at CircleCI kan tolke resultatet. 
Eksempelet nedenfor viser hvordan en slik kjøring kan settes opp. Parameteret `--folder` kan angis flere ganger dersom du vil være eksplisitt på hva du ønsker å kjøre. I noen tilfeller kan man eksempelvis ha tester man ønsker å ha definert, men som foreløpig ikke passer for automatisering.
```bash
npm install -g newman newman-reporter-junitfull
newman run '[COLLECTION_NAME].postman_collection.json' \
              -e [ENVIRONMENT].postman_environment.json \
              --folder [TEST FOLDER 1] \
              --folder [TEST FOLDER 2] \
              -r junit,cli --reporter-junit-export './test-results/postman/result.xml'
```

En ulempe med Postman verktøyet er at man ikke kan angi en lokal fil for en "collection". Dette innebærer at man ved endringer må eksportere "collections" og "environments" manuelt og erstatte filene i kildekoden. Dette kan føre til noen uheldige situasjoner der endringer i kode og tester ikke blir sjekket inn sammen dersom man glemmer å eksportere.

## CircleCI

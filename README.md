# AL-NetCom

## Miljøafgift

- Åbn **NetCom-opsætning** via søgningen, og angiv **Miljøafgift pr. kg**.
- Vælg **Opdater alle varer** for at se emballagevarer med en ændret beregnet
  miljøafgift. Ingen varer rettes, før **Opdater varer** vælges.
- **Opdater varer** retter alle forslag i forhåndsvisningen, også ved aktive
  filtre. Luk skærmbilledet uden at opdatere for at annullere.
- Formlen er `max(Bruttovægt - Nettovægt, 0) * Miljøafgift pr. kg`,
  afrundet til 2 decimaler. Ændring af Emballage, Nettovægt eller Bruttovægt
  via feltvalidering genberegner afgiften. Fjernes Emballage, sættes afgiften til 0.
- Opsætningen skal findes, før emballagevarers felter valideres. En sats på 0
  er tilladt. Ændring af satsen retter ikke automatisk eksisterende varer;
  brug forhåndsvisningen.
- Hvis en foreslået vare eller satsen ændres efter åbning af forhåndsvisningen,
  afvises hele opdateringen. Åbn forhåndsvisningen igen for at få aktuelle forslag.
- Brugere skal have rettighedssættet `NetCom_Permissions` samt rettigheder til
  at læse og rette varer.
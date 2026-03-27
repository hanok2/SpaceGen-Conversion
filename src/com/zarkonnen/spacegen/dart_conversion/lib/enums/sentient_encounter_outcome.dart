enum SentientEncounterOutcome {
  subjugate('They subjugate the local \$a.'),
  giveFullMembership('They incorporate the local \$a into their civilization as equals.'),
  ignore('They ignore the local \$a.'),
  exterminate('They mount a campaign of extermination against the local \$a'),
  exterminateFail('They attempt to exterminate the local \$a');

  final String desc;
  
  const SentientEncounterOutcome(this.desc);
}

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Polyline.create(
  activity_name: "test",
  summary: "o_cqFheu_SKDKGK?GG[DWCIEM@OASDMAMEKBKGe@L[IGF@@ACBA?BUDEVEBALA`@Fh@Ax@ANCDEXARDR`@GCB@AC?EBKHCF?TMCMLCE?ML?AHHG@FGF?CG\\FK@BEGKF@KBAGKECGU@MBABBKJ@K@A?FEF@??DAK@B?CFCCD@EACGBB@?ADTAA@QFKT?PG?CHF?CD@?D?GQOUACO?KDGFAF@@EJCOcAFQ?MDOC_@CE@OEQ?CF?@CEEBEf@BFCRD\\C@GD@BFNQNBFFLETHJKFA?HKL@BVKPMp@EFBPRF?HDBFAJKD@@CA@GA@AC@FAAABJ?@EBAELBA?CCDC?DAAC@JIC@?@GD?G@HC@BIAEHB??OB?DAKD?BB?C@?CJ?@GBDCAB?@BICDDABCG?CBB@CACC@B@@G@DG@B@@CBHGIFFEEBCBBI@AABABFEE?DB@@AA?@??E?BAA@AIAB?AD?IA@FFIE@E@FB??KC@?A?HDACBAE?DB@EED?@C?BAA?@A?TLMGKAATEB?EFATKC??AFAB@EAGDK?HCCBC?@AHCA@ADKAB?EDAEDAEDDGFAG@C@GEBAAFB?AD@GDA?ECB@DD?ACA@BCAB@A?CB?CDFASCHAG@J?MBAIA?HH@ICC@NG@CCLBI?A@@KAH@GA?FA",
  detail: "o_cqFheu_SKDKGK?GG[DWCIEM@OASDMAMEKBKGe@L[IGF@@ACBA?BUDEVEBALA`@Fh@Ax@ANCDEXARDR`@GCB@AC?EBKHCF?TMCMLCE?ML?AHHG@FGF?CG\\FK@BEGKF@KBAGKECGU@MBABBKJ@K@A?FEF@??DAK@B?CFCCD@EACGBB@?ADTAA@QFKT?PG?CHF?CD@?D?GQOUACO?KDGFAF@@EJCOcAFQ?MDOC_@CE@OEQ?CF?@CEEBEf@BFCRD\\C@GD@BFNQNBFFLETHJKFA?HKL@BVKPMp@EFBPRF?HDBFAJKD@@CA@GA@AC@FAAABJ?@EBAELBA?CCDC?DAAC@JIC@?@GD?G@HC@BIAEHB??OB?DAKD?BB?C@?CJ?@GBDCAB?@BICDDABCG?CBB@CACC@B@@G@DG@B@@CBHGIFFEEBCBBI@AABABFEE?DB@@AA?@??E?BAA@AIAB?AD?IA@FFIE@E@FB??KC@?A?HDACBAE?DB@EED?@C?BAA?@A?TLMGKAATEB?EFATKC??AFAB@EAGDK?HCCBC?@AHCA@ADKAB?EDAEDAEDDGFAG@C@GEBAAFB?AD@GDA?ECB@DD?ACA@BCAB@A?CB?CDFASCHAG@J?MBAIA?HH@ICC@NG@CCLBI?A@@KAH@GA?FA",
  started_at: DateTime.now - 24.hours
)

# GrabPolylines.new.create_polylines to populate DB w/basic info


Polyline.all.each do |p|
  p.update(started_at: (1.10).days.ago)
end

Polyline.all.sort_by(&:started_at).pluck(:id)
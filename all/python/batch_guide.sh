#!/bin/bash

#./guide.py --bench=fotonik3d  --size=large --config=profile_all_and_pagemap --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=25769803776 --absolute --report
#./guide.py --bench=fotonik3d  --size=large --config=profile_all_and_pagemap --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=17179869184 --absolute --report
#./guide.py --bench=fotonik3d  --size=large --config=profile_all_and_pagemap --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=8589934592  --absolute --report
#./guide.py --bench=fotonik3d  --size=large --config=profile_all_and_pagemap --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=0           --absolute --report

./guide.py --bench=lulesh  --size=small --config=profile_all_and_pagemap --args=256_10000 --perkey=per_site --valkey=touched --wgtkey=accesses --type=knapsack --upper=1 --lower=0 --capacity=1.0
./guide.py --bench=lulesh  --size=small --config=profile_all_and_pagemap --args=256_10000 --perkey=per_site --valkey=touched --wgtkey=accesses --type=knapsack --upper=1 --lower=0 --capacity=2.0
./guide.py --bench=lulesh  --size=small --config=profile_all_and_pagemap --args=256_10000 --perkey=per_site --valkey=touched --wgtkey=accesses --type=knapsack --upper=1 --lower=0 --capacity=5.0
#./guide.py --bench=lulesh  --size=large --config=profile_all_exclusive_device --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=17179869184 --absolute --report
#./guide.py --bench=lulesh  --size=large --config=profile_all_exclusive_device --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=8589934592  --absolute --report
#./guide.py --bench=lulesh  --size=large --config=profile_all_exclusive_device --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=0           --absolute --report

#./guide.py --bench=amg     --size=large --config=profile_all_exclusive_device --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=25769803776 --absolute --report
#./guide.py --bench=amg     --size=large --config=profile_all_exclusive_device --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=17179869184 --absolute --report
#./guide.py --bench=amg     --size=large --config=profile_all_exclusive_device --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=8589934592  --absolute --report
#./guide.py --bench=amg     --size=large --config=profile_all_exclusive_device --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=0           --absolute --report
#
#./guide.py --bench=snap    --size=large --config=profile_all_and_pagemap      --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=25769803776 --absolute --report
#./guide.py --bench=snap    --size=large --config=profile_all_and_pagemap      --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=17179869184 --absolute --report
#./guide.py --bench=snap    --size=large --config=profile_all_and_pagemap      --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=8589934592  --absolute --report
#./guide.py --bench=snap    --size=large --config=profile_all_and_pagemap      --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=0           --absolute --report
#
#./guide.py --bench=qmcpack --size=large --config=profile_all_and_pagemap      --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=25769803776 --absolute --report
#./guide.py --bench=qmcpack --size=large --config=profile_all_and_pagemap      --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=17179869184 --absolute --report
#./guide.py --bench=qmcpack --size=large --config=profile_all_and_pagemap      --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=8589934592  --absolute --report
#./guide.py --bench=qmcpack --size=large --config=profile_all_and_pagemap      --args=256_10000 --perkey=per_site --valkey=accs_site --wgtkey=touched --type=hotset --upper=1 --lower=0 --capacity=0           --absolute --report

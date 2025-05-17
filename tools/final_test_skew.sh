#!/usr/bin/env bash
rm -rf /users/peiqi714/test/skew_log/*
rm -rf /users/peiqi714/test/db/*
thread_count=1
echo "start final exp skew"
for skewness in 0 0.3 0.6 1.2 
do
    entry_count=$((50000000/(1024 / 1024)))
    echo "entry count: $entry_count"
    echo "skewness: $skewness"

    # rocksdb
    rm -rf /users/peiqi714/test/db/*
    ../rocksdb_6_29/build/db_bench --benchmarks=fillrandom,stats,overwrite,stats  --db=/users/peiqi714/test/db/db --threads=$thread_count \
                    --statistics=true  --num=$entry_count  --zipfian=1 --zipf_const=$skewness \
                    --key_size=16 --value_size=1024 --compression_type=none --compression_ratio=1 > /users/peiqi714/test/skew_log/rocksdb_skew${skewness}
    echo "rocksdb_skew${skewness} space:" >> /users/peiqi714/test/skew_log/space_util_skew
    du -k --max-depth=0 /users/peiqi714/test/db/db >> /users/peiqi714/test/skew_log/space_util_skew
    cp -f /users/peiqi714/test/db/db/LOG /users/peiqi714/test/skew_log/rocksdb_skew${skewness}_LOG

    # blobdb
    rm -rf /users/peiqi714/test/db/*
    ../rocksdb_6_29/build/db_bench --benchmarks=fillrandom,stats,overwrite,stats  --db=/users/peiqi714/test/db/db --threads=$thread_count \
                    --statistics=true  --num=$entry_count --zipfian=1 --zipf_const=$skewness \
                    --key_size=16 --value_size=1024 --compression_type=none --compression_ratio=1 \
                    --enable_blob_files=true --enable_blob_garbage_collection=true \
                    --blob_garbage_collection_force_threshold=0.3 --target_file_size_base=4194304 \
                    --max_bytes_for_level_base=16777216 --blob_file_size=67108864 > /users/peiqi714/test/skew_log/blobdb_skew${skewness}
    echo "blobdb_skew${skewness} space:" >> /users/peiqi714/test/skew_log/space_util_skew
    du -k --max-depth=0 /users/peiqi714/test/db/db >> /users/peiqi714/test/skew_log/space_util_skew
    cp -f /users/peiqi714/test/db/db/LOG /users/peiqi714/test/skew_log/blobdb_skew${skewness}_LOG


    # diffkv
    rm -rf /users/peiqi714/test/db/*
    ./titandb_bench --benchmarks=fillrandom,stats,overwrite,stats  --db=/users/peiqi714/test/db/db --threads=$thread_count \
                    --statistics=true  --num=$entry_count --zipfian=1 --zipf_const=$skewness \
                    --key_size=16 --value_size=1024 --compression_type=none \
                    --level_compaction_dynamic_level_bytes=true --titan_level_merge=true --titan_disable_background_gc=true \
                    --titan_blob_file_discardable_ratio=0.3 --target_file_size_base=4194304 \
                    --max_bytes_for_level_base=16777216 --titan_blob_file_target_size=67108864 \
                    --titan_merge_small_file_threshold=2097152 --titan_min_gc_batch_size=134217728 \
                    --titan_max_gc_batch_size=268435456 > /users/peiqi714/test/skew_log/diffkv_skew${skewness}
    echo "diffkv_skew${skewness} space:" >> /users/peiqi714/test/skew_log/space_util_skew
    du -k --max-depth=0 /users/peiqi714/test/db/db >> /users/peiqi714/test/skew_log/space_util_skew
    cp -f /users/peiqi714/test/db/db/LOG /users/peiqi714/test/skew_log/diffkv_skew${skewness}_LOG

    # titan
    rm -rf /users/peiqi714/test/db/*
    ./titandb_bench --benchmarks=fillrandom,stats,overwrite,stats  --db=/users/peiqi714/test/db/db --threads=$thread_count \
                    --statistics=true  --num=$entry_count --zipfian=1 --zipf_const=$skewness \
                    --key_size=16 --value_size=1024 --compression_type=none \
                    --titan_blob_file_discardable_ratio=0.3 --target_file_size_base=4194304 \
                    --max_bytes_for_level_base=16777216 --titan_blob_file_target_size=67108864 \
                    --titan_merge_small_file_threshold=2097152 --titan_min_gc_batch_size=134217728 \
                    --titan_max_gc_batch_size=268435456 > /users/peiqi714/test/skew_log/titan_skew${skewness}
    echo "titan_skew${skewness} space:" >> /users/peiqi714/test/skew_log/space_util_skew
    du -k --max-depth=0 /users/peiqi714/test/db/db >> /users/peiqi714/test/skew_log/space_util_skew
    cp -f /users/peiqi714/test/db/db/LOG /users/peiqi714/test/skew_log/titan_skew${skewness}_LOG

    # shadow
    rm -rf /users/peiqi714/test/db/*
    ./titandb_bench --benchmarks=fillrandom,stats,overwrite,stats  --db=/users/peiqi714/test/db/db --threads=$thread_count \
                    --statistics=true  --num=$entry_count --zipfian=1 --zipf_const=$skewness \
                    --key_size=16 --value_size=1024 --compression_type=none \
                    --titan_drop_key_bitset=1 --titan_shadow_cache=1 \
                    --titan_blob_file_discardable_ratio=0.3 --target_file_size_base=4194304 \
                    --max_bytes_for_level_base=16777216 --titan_blob_file_target_size=67108864 \
                    --titan_merge_small_file_threshold=2097152 --titan_min_gc_batch_size=134217728 \
                    --titan_max_gc_batch_size=268435456 > /users/peiqi714/test/skew_log/shadow_skew${skewness}
    echo "shadow_skew${skewness} space:" >> /users/peiqi714/test/skew_log/space_util_skew
    du -k --max-depth=0 /users/peiqi714/test/db/db >> /users/peiqi714/test/skew_log/space_util_skew
    cp -f /users/peiqi714/test/db/db/LOG /users/peiqi714/test/skew_log/shadow_skew${skewness}_LOG

done
echo "end final exp skew"
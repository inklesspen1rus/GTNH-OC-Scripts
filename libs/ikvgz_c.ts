// import * as component from 'component';
// const data = component.data;

/**
 * @param keyvalues keyvalues, sorted by key
 * @param path output path
 * @param path_tmp tmp file path
 * @param memlimit memory limit in bytes
 * @returns error or nil
 */
export function pack_into_file(keyvalues: [string, string][], path: string, path_tmp: string, memlimit: number = 32 * 1024): string | undefined {
    let kfile: LuaFile | undefined = undefined;
    let vfile: LuaFile | undefined = undefined;

    function core(): string | undefined {
        if (!kfile || !vfile) {
            return "Failed.";
        }

        let vfile_cur = 0;

        let first_key_entry: string | undefined = undefined;
        let keys: string = '';
        let values: string = '';
        const state_limit = memlimit / 4;
        let state_mem = 0;

        function flush(): string | undefined {
            if (!first_key_entry) {
                return;
            }

            // let values_c: string | undefined = data.deflate(values);
            let values_c: string | undefined = (values);
            const values_c_size = values_c.length;
            let [_, err] = vfile!.write(string.format('%08x', values_c_size) + values_c);
            values_c = undefined;

            if (err !== undefined) {
                return "Failed 1";
            }

            // let keys_c: string | undefined = data.deflate(keys);
            let keys_c: string | undefined = (keys);
            const keys_c_size = keys_c.length;
            [_, err] = kfile!.write(string.format('%08x', keys_c_size) + string.format('%08x', vfile_cur) + first_key_entry + keys_c);
            keys_c = undefined;

            if (err !== undefined) {
                return "Failed 2";
            }

            vfile_cur += 8 + values_c_size;

            first_key_entry = undefined;
            keys = ''
            values = ''
            state_mem = 0
        }

        for (const [key, value] of keyvalues) {
            first_key_entry ??= string.format('%08x', key.length) + key;
            keys += string.format('%08x', key.length) + key;
            values += string.format('%08x', value.length) + value;
            state_mem += key.length + value.length;


            if (state_mem >= state_limit) {
                const r = flush()
                if (r) return r;
            }
        }
        const r = flush()
        if (r) return r;
    }

    try {
        kfile = io.open(path, 'w')[0];
        vfile = io.open(path_tmp, 'w')[0];

        return core();
    } catch (e) {
        print(e)
    } finally {
        kfile?.close();
        vfile?.close();
    }
}
import json from '@rollup/plugin-json';
import { terser } from "rollup-plugin-terser";
import { nodeResolve } from '@rollup/plugin-node-resolve';

export default [
    {
        input: 'DuckDuckGo/Autoconsent/userscript.js',
        output: [
            {
                file: 'DuckDuckGo/Autoconsent/autoconsent-bundle.js',
                format: 'iife'
            }
        ],
        plugins: [
            nodeResolve(),
            json(),
            terser(),
        ]
    }
]

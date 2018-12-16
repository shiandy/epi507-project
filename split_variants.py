import argparse

CHROM = list(map(str, range(1, 23)))
CHROM.append("X")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("fname", help = "Input variants file")

    args = parser.parse_args()

    # open all the files
    outfiles_dict = dict()
    for chrom in CHROM:
        # hard code file name
        fname = "nealelab-uk-biobank/variants_chr" + chrom + ".tsv"
        f = open(fname, "w")
        outfiles_dict[chrom] = f

    with open(args.fname) as f:
        line1 = f.readline()
        for key, outfile in outfiles_dict.items():
            outfile.write(line1)
        for line in f:
            chrom = line.split("\t")[1]
            out_f = outfiles_dict[chrom]
            out_f.write(line)

    for key, outfile in outfiles_dict.items():
        outfile.close()

if __name__ == "__main__":
    main()

import argparse

##gfffile='/pym/Data/Nanopore/projects/prolificans/nina_annot/st31.final2.fasta.functional_note.pseudo_label.gff'
##valfile='/pym/Data/Nanopore/projects/prolificans/nina_annot/st31.val'
##gfffile='/pym/Data/Nanopore/projects/prolificans/nina_annot/st31.final2.fasta.functional_note.pseudo_label.yfan.gff'

def parseArgs():
    parser = argparse.ArgumentParser(description='add pseudo label to gff')
    parser.add_argument('-g','--gfffile', type=str, required=True, 
            help="gff file that lacks pseudogene annotations")
    parser.add_argument('-o','--outfile', type=str, required=True, 
            help="output for new gff")
    args = parser.parse_args()
    return(args)


def main(gfffile, outfile):
    ##read in the gff
    with open(gfffile, 'r') as f:
        gff = f.read().split('\n')

    gff = list(filter(None, gff))

    ##get initial list of parents that have a pseudo child
    pseudos = []
    for i in gff:
        if 'pseudogene=unknown' in i:
            idinfo = i.split('\t')[8]
            parent = idinfo.split('Parent=')[1].split(';')[0]
            pseudos.append(parent)
    pseudos_unique = list(set(pseudos))

    ##get parents of parents until gene features are reached
    stop = False
    while not stop:
        new = []
        for i in gff:
            for j in pseudos_unique:
                if j in i: ##if a pseudo id is found in the line, add the parent
                    idinfo = i.split('\t')[8]
                    if "Parent=" in i:
                        parent = idinfo.split('Parent=')[1].split(';')[0]
                    new.append(parent)
        ##update pseudos list
        toadd = list(set(new))
        newpseudos_unique = list(set(pseudos_unique + toadd))
        if len(newpseudos_unique)==len(pseudos_unique):
            stop = True
        else:
            pseudos_unique = newpseudos_unique

    ##tag parents as pseudo
    newgff = []
    for i in gff:
        added = False
        ##loop through locations list and see if the line needs a pseudo
        for j in pseudos_unique:
            if "ID="+j in i and 'pseudogene=unknown' not in i:
                added = True
                if i.endswith(';'):
                    newgff.append(i+'pseudogene=unknown;'+'\n')
                else:
                    newgff.append(i+';pseudogene=unknown'+'\n')
                break
        ##if pseudo not needed, add back the line as is
        if not added:
            newgff.append(i+'\n')

    with open(outfile, 'w') as f:
        for i in newgff:
            f.write(i)
        
if __name__=="__main__":
    args = parseArgs()
    main(args.gfffile, args.outfile)
    
